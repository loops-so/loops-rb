# frozen_string_literal: true

require "base64"
require "json"
require "openssl"

module LoopsSdk
  class WebhookVerificationError < StandardError
    attr_reader :code

    def initialize(message, code)
      @code = code
      super(message)
    end
  end

  class Webhooks
    SECRET_PREFIX = "whsec_"
    DEFAULT_TOLERANCE_SECONDS = 300

    class << self
      # Verifies that a webhook request was signed by Loops.
      #
      # Uses the signing secret from Settings → Webhooks. Pass the raw request
      # body string, not a parsed JSON object.
      #
      # @param headers [Hash, #each] Request headers. Accepts a plain hash
      #   (string or symbol keys) or any object that yields key/value pairs
      #   via +each+ (for example Rails +request.headers+).
      # @param raw_body [String] Exact raw request body. Do not pass a parsed
      #   JSON object — parsing or reformatting breaks signature verification.
      # @param secret [String] Webhook signing secret (often +LOOPS_SIGNING_SECRET+).
      #   May include the +whsec_+ prefix.
      # @param tolerance_seconds [Integer] Maximum allowed age of the webhook
      #   timestamp, in seconds. Defaults to 300 (5 minutes).
      # @return [Hash] The parsed JSON payload when verification succeeds.
      # @raise [WebhookVerificationError] When headers, timestamp, signature,
      #   secret, or body are invalid.
      def verify(headers:, raw_body:, secret:, tolerance_seconds: DEFAULT_TOLERANCE_SECONDS)
        if secret.nil? || secret.empty?
          raise WebhookVerificationError.new(
            "Missing webhook signing secret",
            "MISSING_SECRET"
          )
        end

        id = webhook_header(headers, "webhook-id")
        timestamp = webhook_header(headers, "webhook-timestamp")
        signature_header = webhook_header(headers, "webhook-signature")

        if id.nil? || timestamp.nil? || signature_header.nil?
          raise WebhookVerificationError.new(
            "Missing webhook-id, webhook-timestamp, or webhook-signature header",
            "MISSING_HEADERS"
          )
        end

        begin
          ts = Float(timestamp)
        rescue ArgumentError, TypeError
          raise WebhookVerificationError.new(
            "webhook-timestamp is not a valid number",
            "INVALID_TIMESTAMP"
          )
        end

        now = Time.now.to_i
        if (now - ts).abs > tolerance_seconds
          raise WebhookVerificationError.new(
            "webhook-timestamp is outside the allowed tolerance",
            "INVALID_TIMESTAMP"
          )
        end

        encoded = if secret.start_with?(SECRET_PREFIX)
                    secret[SECRET_PREFIX.length..]
                  else
                    secret
                  end
        key = Base64.decode64(encoded)

        expected = Base64.strict_encode64(
          OpenSSL::HMAC.digest("SHA256", key, "#{id}.#{timestamp}.#{raw_body}")
        )

        matched = signature_header.split(/\s+/).any? do |entry|
          comma = entry.index(",")
          next false if comma.nil?

          version = entry[0...comma]
          value = entry[(comma + 1)..]
          version == "v1" && timing_safe_equal?(value, expected)
        end

        unless matched
          raise WebhookVerificationError.new(
            "Invalid signature",
            "INVALID_SIGNATURE"
          )
        end

        begin
          JSON.parse(raw_body)
        rescue JSON::ParserError
          raise WebhookVerificationError.new(
            "Webhook body is not valid JSON",
            "INVALID_BODY"
          )
        end
      end

      private

      def webhook_header(headers, name)
        target = name.downcase
        rack_key = "HTTP_#{name.upcase.tr("-", "_")}"
        rack_target = rack_key.downcase

        if headers.respond_to?(:[])
          [
            name,
            name.downcase,
            name.upcase,
            name.split("-").map(&:capitalize).join("-"),
            rack_key
          ].uniq.each do |key|
            value = headers[key]
            normalized = normalize_header_value(value)
            return normalized unless normalized.nil?
          end
        end

        return nil unless headers.respond_to?(:each)

        headers.each do |key, value|
          key_name = key.to_s.downcase
          next unless key_name == target || key_name == rack_target

          normalized = normalize_header_value(value)
          return normalized unless normalized.nil?
        end

        nil
      end

      def normalize_header_value(value)
        return nil if value.nil?

        if value.is_a?(Array)
          return nil if value.empty?

          return value.join(" ")
        end

        string = value.to_s
        string.empty? ? nil : string
      end

      def timing_safe_equal?(left, right)
        return false if left.bytesize != right.bytesize

        OpenSSL.fixed_length_secure_compare(left, right)
      end
    end
  end
end
