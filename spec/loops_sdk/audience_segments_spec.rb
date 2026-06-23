# frozen_string_literal: true

require "spec_helper"

RSpec.describe LoopsSdk::AudienceSegments do
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
    it "makes a GET request to list audience segments" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/audience-segments")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({ cursor: nil, perPage: 20 })
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
    it "makes a GET request to fetch an audience segment" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/audience-segments/segment_123")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"id":"segment_123"}')

      result = described_class.get(id: "segment_123")
      expect(result).to eq({ "id" => "segment_123" })
    end
  end
end
