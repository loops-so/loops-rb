# frozen_string_literal: true

require "spec_helper"

RSpec.describe LoopsSdk::Footers do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response) }
  let(:default_headers) do
    {
      "Authorization" => "Bearer test-key",
      "Content-Type" => "application/json"
    }
  end
  let(:footer_id) { "clf0o1t2e3r4i5d6a7b8c9d0" }
  let(:variant_id) { "clv1a2r3i4a5n6t7i8d9e0f1" }

  before do
    allow(LoopsSdk.configuration).to receive(:connection).and_return(connection)
    allow(connection).to receive(:headers).and_return(default_headers)
  end

  describe ".list" do
    it "makes a GET request to list footers" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({ perPage: 20, cursor: nil })
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"data":[]}')

      result = described_class.list
      expect(result).to eq({ "data" => [] })
    end
  end

  describe ".get" do
    it "makes a GET request for a footer" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers/#{footer_id}")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return(%({"id":"#{footer_id}"}))

      result = described_class.get(footer_id: footer_id)
      expect(result).to eq({ "id" => footer_id })
    end
  end

  describe ".create" do
    it "makes a POST request to create a footer" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ name: "Main footer" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(201)
      allow(response).to receive(:body).and_return(%({"id":"#{footer_id}"}))

      result = described_class.create(name: "Main footer")
      expect(result).to eq({ "id" => footer_id })
    end
  end

  describe ".update" do
    it "makes a POST request to update a footer" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers/#{footer_id}")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ name: "Marketing footer", placement: "below" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return(%({"id":"#{footer_id}"}))

      result = described_class.update(footer_id: footer_id, name: "Marketing footer", placement: "below")
      expect(result).to eq({ "id" => footer_id })
    end
  end

  describe ".delete" do
    it "makes a DELETE request to delete a footer" do
      expect(connection).to receive(:send).with(:delete) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers/#{footer_id}")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(204)
      allow(response).to receive(:body).and_return("")

      result = described_class.delete(footer_id: footer_id)
      expect(result).to be_nil
    end
  end

  describe ".set_default" do
    it "makes a POST request to set the default footer" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers/#{footer_id}/set-default")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ existingEmails: "all" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return(%({"id":"#{footer_id}","updatedEmailCount":12}))

      result = described_class.set_default(footer_id: footer_id, existing_emails: "all")
      expect(result).to eq({ "id" => footer_id, "updatedEmailCount" => 12 })
    end
  end

  describe ".get_variant" do
    it "makes a GET request for a footer variant" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers/#{footer_id}/variants/#{variant_id}")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return(%({"id":"#{variant_id}"}))

      result = described_class.get_variant(footer_id: footer_id, variant_id: variant_id)
      expect(result).to eq({ "id" => variant_id })
    end
  end

  describe ".update_variant" do
    it "makes a POST request to update a footer variant" do
      expected_body = {
        expectedRevisionId: "clr2e3v4i5s6i7o8n9i0d1e2",
        lmx: "{system.company_name}"
      }

      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers/#{footer_id}/variants/#{variant_id}")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(expected_body.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return(%({"id":"#{variant_id}"}))

      result = described_class.update_variant(
        footer_id: footer_id,
        variant_id: variant_id,
        expected_revision_id: "clr2e3v4i5s6i7o8n9i0d1e2",
        lmx: "{system.company_name}"
      )
      expect(result).to eq({ "id" => variant_id })
    end
  end

  describe ".publish_variant" do
    it "makes a POST request to publish a footer variant" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/footers/#{footer_id}/variants/#{variant_id}/publish")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ expectedRevisionId: "clr2e3v4i5s6i7o8n9i0d1e2" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return(%({"id":"#{variant_id}"}))

      result = described_class.publish_variant(
        footer_id: footer_id,
        variant_id: variant_id,
        expected_revision_id: "clr2e3v4i5s6i7o8n9i0d1e2"
      )
      expect(result).to eq({ "id" => variant_id })
    end
  end
end
