# frozen_string_literal: true

require "spec_helper"
require "base64"
require "openssl"
require "securerandom"

RSpec.describe LoopsSdk::Webhooks do
  let(:secret_bytes) { SecureRandom.random_bytes(32) }
  let(:secret) { "whsec_#{Base64.strict_encode64(secret_bytes)}" }
  let(:secret_without_prefix) { Base64.strict_encode64(secret_bytes) }

  def sign(id:, timestamp:, raw_body:, secret: self.secret)
    encoded = secret.start_with?("whsec_") ? secret.delete_prefix("whsec_") : secret
    key = Base64.decode64(encoded)
    digest = Base64.strict_encode64(
      OpenSSL::HMAC.digest("SHA256", key, "#{id}.#{timestamp}.#{raw_body}")
    )
    "v1,#{digest}"
  end

  def valid_payload(overrides = {})
    id = overrides.fetch(:id, "msg_test_123")
    timestamp = overrides.fetch(:timestamp, Time.now.to_i)
    raw_body = overrides.fetch(:raw_body, JSON.generate({ "eventName" => "email.sent" }))
    used_secret = overrides.fetch(:secret, secret)
    signature = sign(id: id, timestamp: timestamp, raw_body: raw_body, secret: used_secret)
    signatures = [signature, *Array(overrides[:extra_signatures])].join(" ")

    {
      id: id,
      timestamp: timestamp.to_s,
      raw_body: raw_body,
      headers: {
        "webhook-id" => id,
        "webhook-timestamp" => timestamp.to_s,
        "webhook-signature" => signatures
      }
    }
  end

  it "verifies a valid request and returns the parsed payload" do
    payload = valid_payload

    event = LoopsSdk::Webhooks.verify(
      headers: payload[:headers],
      raw_body: payload[:raw_body],
      secret: secret
    )

    expect(event).to eq({ "eventName" => "email.sent" })
  end

  it "accepts secrets without the whsec_ prefix" do
    payload = valid_payload(secret: secret_without_prefix)

    expect do
      LoopsSdk::Webhooks.verify(
        headers: payload[:headers],
        raw_body: payload[:raw_body],
        secret: secret_without_prefix
      )
    end.not_to raise_error
  end

  it "matches any v1 signature when multiple are present" do
    payload = valid_payload(extra_signatures: ["v1,not-a-real-signature", "v0,ignored"])

    expect do
      LoopsSdk::Webhooks.verify(
        headers: payload[:headers],
        raw_body: payload[:raw_body],
        secret: secret
      )
    end.not_to raise_error
  end

  it "is case-insensitive for header names" do
    payload = valid_payload
    signature = sign(
      id: payload[:id],
      timestamp: payload[:timestamp],
      raw_body: payload[:raw_body]
    )

    event = LoopsSdk::Webhooks.verify(
      headers: {
        "Webhook-Id" => payload[:id],
        "Webhook-Timestamp" => payload[:timestamp],
        "Webhook-Signature" => signature
      },
      raw_body: payload[:raw_body],
      secret: secret
    )

    expect(event).to eq({ "eventName" => "email.sent" })
  end

  it "joins array header values" do
    payload = valid_payload
    good = sign(
      id: payload[:id],
      timestamp: payload[:timestamp],
      raw_body: payload[:raw_body]
    )

    event = LoopsSdk::Webhooks.verify(
      headers: {
        "webhook-id" => [payload[:id]],
        "webhook-timestamp" => [payload[:timestamp]],
        "webhook-signature" => ["v1,bad-signature", good]
      },
      raw_body: payload[:raw_body],
      secret: secret
    )

    expect(event).to eq({ "eventName" => "email.sent" })
  end

  it "throws MISSING_SECRET when secret is empty" do
    payload = valid_payload

    expect do
      LoopsSdk::Webhooks.verify(
        headers: payload[:headers],
        raw_body: payload[:raw_body],
        secret: ""
      )
    end.to raise_error(LoopsSdk::WebhookVerificationError) { |error|
      expect(error.code).to eq("MISSING_SECRET")
    }
  end

  it "throws MISSING_HEADERS when a required header is absent" do
    payload = valid_payload

    expect do
      LoopsSdk::Webhooks.verify(
        headers: {
          "webhook-id" => "msg_test_123",
          "webhook-timestamp" => Time.now.to_i.to_s
        },
        raw_body: payload[:raw_body],
        secret: secret
      )
    end.to raise_error(LoopsSdk::WebhookVerificationError) { |error|
      expect(error.code).to eq("MISSING_HEADERS")
    }
  end

  it "throws INVALID_TIMESTAMP for a non-numeric timestamp" do
    payload = valid_payload

    expect do
      LoopsSdk::Webhooks.verify(
        headers: {
          "webhook-id" => payload[:id],
          "webhook-timestamp" => "not-a-number",
          "webhook-signature" => "v1,abc"
        },
        raw_body: payload[:raw_body],
        secret: secret
      )
    end.to raise_error(LoopsSdk::WebhookVerificationError) { |error|
      expect(error.code).to eq("INVALID_TIMESTAMP")
    }
  end

  it "throws INVALID_TIMESTAMP when the timestamp is outside tolerance" do
    stale = Time.now.to_i - 301
    payload = valid_payload(timestamp: stale)

    expect do
      LoopsSdk::Webhooks.verify(
        headers: payload[:headers],
        raw_body: payload[:raw_body],
        secret: secret
      )
    end.to raise_error(LoopsSdk::WebhookVerificationError) { |error|
      expect(error.code).to eq("INVALID_TIMESTAMP")
    }
  end

  it "allows a custom tolerance_seconds" do
    stale = Time.now.to_i - 301
    payload = valid_payload(timestamp: stale)

    expect do
      LoopsSdk::Webhooks.verify(
        headers: payload[:headers],
        raw_body: payload[:raw_body],
        secret: secret,
        tolerance_seconds: 600
      )
    end.not_to raise_error
  end

  it "throws INVALID_SIGNATURE for a bad signature" do
    payload = valid_payload

    expect do
      LoopsSdk::Webhooks.verify(
        headers: {
          "webhook-id" => payload[:id],
          "webhook-timestamp" => payload[:timestamp],
          "webhook-signature" => "v1,dGhpc2lzbm90YXJlYWxzaWduYXR1cmU="
        },
        raw_body: payload[:raw_body],
        secret: secret
      )
    end.to raise_error(LoopsSdk::WebhookVerificationError) { |error|
      expect(error.code).to eq("INVALID_SIGNATURE")
    }
  end

  it "throws INVALID_SIGNATURE when the body has been altered" do
    payload = valid_payload

    expect do
      LoopsSdk::Webhooks.verify(
        headers: payload[:headers],
        raw_body: JSON.generate({ "eventName" => "tampered" }),
        secret: secret
      )
    end.to raise_error(LoopsSdk::WebhookVerificationError) { |error|
      expect(error.code).to eq("INVALID_SIGNATURE")
    }
  end

  it "throws INVALID_BODY when the verified body is not JSON" do
    raw_body = "not-json"
    id = "msg_test_123"
    timestamp = Time.now.to_i.to_s

    expect do
      LoopsSdk::Webhooks.verify(
        headers: {
          "webhook-id" => id,
          "webhook-timestamp" => timestamp,
          "webhook-signature" => sign(id: id, timestamp: timestamp, raw_body: raw_body)
        },
        raw_body: raw_body,
        secret: secret
      )
    end.to raise_error(LoopsSdk::WebhookVerificationError) { |error|
      expect(error.code).to eq("INVALID_BODY")
    }
  end
end
