# frozen_string_literal: true

require "spec_helper"

RSpec.describe LoopsSdk::WorkflowGroups do
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

  describe ".create" do
    it "makes a POST request to create a workflow group" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/workflow-groups")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ name: "Onboarding", description: "Signup flows" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"id":"clw8x0y2z0300ycc1lrstvw78"}')

      result = described_class.create(name: "Onboarding", description: "Signup flows")
      expect(result).to eq({ "id" => "clw8x0y2z0300ycc1lrstvw78" })
    end
  end
end
