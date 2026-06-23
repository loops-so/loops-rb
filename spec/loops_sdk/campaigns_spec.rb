# frozen_string_literal: true

require "spec_helper"

RSpec.describe LoopsSdk::Campaigns do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response) }
  let(:default_headers) do
    {
      "Authorization" => "Bearer test-key",
      "Content-Type" => "application/json"
    }
  end

  before do
    allow(LoopsSdk.configuration).to receive(:connection).and_return(connection)
    allow(connection).to receive(:headers).and_return(default_headers)
  end

  describe ".list" do
    it "makes a GET request to list campaigns" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/campaigns")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({ cursor: nil, perPage: 20 })
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"success":true,"data":[]}')

      result = described_class.list
      expect(result).to eq({ "success" => true, "data" => [] })
    end
  end

  describe ".create" do
    it "makes a POST request to create a campaign" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/campaigns")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ name: "Spring announcement" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(201)
      allow(response).to receive(:body).and_return('{"success":true,"campaignId":"camp_123"}')

      result = described_class.create(name: "Spring announcement")
      expect(result).to eq({ "success" => true, "campaignId" => "camp_123" })
    end

    it "includes optional audience and scheduling fields" do
      expected_body = {
        name: "Spring announcement",
        mailingListId: "list_123",
        scheduling: { method: "now" }
      }

      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/campaigns")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=) do |body|
          expect(JSON.parse(body)).to eq(JSON.parse(expected_body.to_json))
        end
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(201)
      allow(response).to receive(:body).and_return('{"id":"camp_123"}')

      result = described_class.create(
        name: "Spring announcement",
        mailing_list_id: "list_123",
        scheduling: { method: "now" }
      )
      expect(result).to eq({ "id" => "camp_123" })
    end
  end

  describe ".update" do
    it "makes a POST request to update a campaign" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/campaigns/camp_123")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ name: "Updated name" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"success":true,"campaignId":"camp_123"}')

      result = described_class.update(id: "camp_123", name: "Updated name")
      expect(result).to eq({ "success" => true, "campaignId" => "camp_123" })
    end
  end
end
