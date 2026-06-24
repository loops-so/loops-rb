# frozen_string_literal: true

require "spec_helper"

RSpec.describe LoopsSdk::Uploads do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:create_response) { instance_double(Faraday::Response) }
  let(:complete_response) { instance_double(Faraday::Response) }
  let(:presigned_response) { instance_double(Faraday::Response) }
  let(:default_headers) do
    {
      "Authorization" => "Bearer test-key",
      "Content-Type" => "application/json"
    }
  end
  let(:image_path) { File.join(__dir__, "../fixtures/test.png") }
  let(:image_data) { File.binread(image_path) }

  before do
    allow(LoopsSdk.configuration).to receive(:connection).and_return(connection)
    allow(connection).to receive(:headers).and_return(default_headers)
  end

  describe ".upload" do
    it "creates an upload, PUTs the file to the presigned URL, and completes the upload" do
      expect(connection).to receive(:send).with(:post).ordered do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/uploads")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(
          { contentType: "image/png", contentLength: image_data.bytesize }.to_json
        )
        block.call(req)
        create_response
      end

      allow(create_response).to receive(:status).and_return(200)
      allow(create_response).to receive(:body).and_return(
        {
          emailAssetId: "clu1v4w6x0254tz42lrcwat45",
          presignedUrl: "https://storage.example.com/upload"
        }.to_json
      )

      expect(Faraday).to receive(:put).with("https://storage.example.com/upload") do |&block|
        req = double("req")
        headers = {}
        allow(req).to receive(:headers).and_return(headers)
        expect(req).to receive(:body=).with(image_data)
        block.call(req)
        expect(headers["Content-Type"]).to eq("image/png")
        expect(headers["Content-Length"]).to eq(image_data.bytesize.to_s)
        presigned_response
      end

      allow(presigned_response).to receive(:success?).and_return(true)

      expect(connection).to receive(:send).with(:post).ordered do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/uploads/clu1v4w6x0254tz42lrcwat45/complete")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        complete_response
      end

      allow(complete_response).to receive(:status).and_return(200)
      allow(complete_response).to receive(:body).and_return(
        { emailAssetId: "clu1v4w6x0254tz42lrcwat45", finalUrl: "https://cdn.example.com/clu1v4w6x0254tz42lrcwat45.png" }.to_json
      )

      result = described_class.upload(path: image_path)
      expect(result).to eq(
        "emailAssetId" => "clu1v4w6x0254tz42lrcwat45",
        "finalUrl" => "https://cdn.example.com/clu1v4w6x0254tz42lrcwat45.png"
      )
    end

    it "uses an explicit content_type when provided" do
      expect(connection).to receive(:send).with(:post).ordered do |&block|
        req = double("req")
        allow(req).to receive(:url)
        allow(req).to receive(:headers=)
        allow(req).to receive(:params=)
        expect(req).to receive(:body=).with(
          { contentType: "image/webp", contentLength: image_data.bytesize }.to_json
        )
        block.call(req)
        create_response
      end

      allow(create_response).to receive(:status).and_return(200)
      allow(create_response).to receive(:body).and_return(
        {
          emailAssetId: "clu1v4w6x0254tz42lrcwat45",
          presignedUrl: "https://storage.example.com/upload"
        }.to_json
      )

      expect(Faraday).to receive(:put) do |&block|
        req = double("req")
        headers = {}
        allow(req).to receive(:headers).and_return(headers)
        allow(req).to receive(:body=)
        block.call(req)
        expect(headers["Content-Type"]).to eq("image/webp")
        presigned_response
      end

      allow(presigned_response).to receive(:success?).and_return(true)

      expect(connection).to receive(:send).with(:post).ordered do |&block|
        req = double("req")
        allow(req).to receive(:url)
        allow(req).to receive(:headers=)
        allow(req).to receive(:params=)
        allow(req).to receive(:body=)
        block.call(req)
        complete_response
      end

      allow(complete_response).to receive(:status).and_return(200)
      allow(complete_response).to receive(:body).and_return(
        { emailAssetId: "clu1v4w6x0254tz42lrcwat45", finalUrl: "https://cdn.example.com/clu1v4w6x0254tz42lrcwat45.png" }.to_json
      )

      described_class.upload(path: image_path, content_type: "image/webp")
    end

    it "raises ArgumentError for unsupported content_type" do
      expect do
        described_class.upload(path: image_path, content_type: "image/bmp")
      end.to raise_error(ArgumentError, /Unsupported content_type/)
    end
  end
end
