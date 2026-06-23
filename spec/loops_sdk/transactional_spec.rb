# frozen_string_literal: true

require "spec_helper"

RSpec.describe LoopsSdk::Transactional do
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
    it "makes a GET request to list transactional emails with default params" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional-emails")
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

    it "makes a GET request with custom params" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional-emails")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({ cursor: "abc", perPage: 5 })
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"data":[]}')

      result = described_class.list(perPage: 5, cursor: "abc")
      expect(result).to eq({ "data" => [] })
    end
  end

  describe ".create" do
    it "makes a POST request to create a transactional email" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional-emails")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ name: "Welcome email" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(201)
      allow(response).to receive(:body).and_return('{"id":"clfq6dinn000yl70fgwwyp82l","draftEmailMessageId":"cly8k3m0n0044jpx2bghepq45"}')

      result = described_class.create(name: "Welcome email")
      expect(result).to eq({ "id" => "clfq6dinn000yl70fgwwyp82l", "draftEmailMessageId" => "cly8k3m0n0044jpx2bghepq45" })
    end
  end

  describe ".get" do
    it "makes a GET request to fetch a transactional email" do
      expect(connection).to receive(:send).with(:get) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional-emails/clfq6dinn000yl70fgwwyp82l")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"id":"clfq6dinn000yl70fgwwyp82l","name":"Welcome email"}')

      result = described_class.get(id: "clfq6dinn000yl70fgwwyp82l")
      expect(result).to eq({ "id" => "clfq6dinn000yl70fgwwyp82l", "name" => "Welcome email" })
    end
  end

  describe ".update" do
    it "makes a POST request to update a transactional email" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional-emails/clfq6dinn000yl70fgwwyp82l")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with({ name: "Updated name" }.to_json)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"id":"clfq6dinn000yl70fgwwyp82l","name":"Updated name"}')

      result = described_class.update(id: "clfq6dinn000yl70fgwwyp82l", name: "Updated name")
      expect(result).to eq({ "id" => "clfq6dinn000yl70fgwwyp82l", "name" => "Updated name" })
    end
  end

  describe ".ensure_draft" do
    it "makes a POST request to ensure a draft email message exists" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional-emails/clfq6dinn000yl70fgwwyp82l/draft")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"id":"clfq6dinn000yl70fgwwyp82l","draftEmailMessageId":"clz2p5q8r0066kqz3chifkr56"}')

      result = described_class.ensure_draft(id: "clfq6dinn000yl70fgwwyp82l")
      expect(result).to eq({ "id" => "clfq6dinn000yl70fgwwyp82l", "draftEmailMessageId" => "clz2p5q8r0066kqz3chifkr56" })
    end
  end

  describe ".publish" do
    it "makes a POST request to publish a transactional email draft" do
      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional-emails/clfq6dinn000yl70fgwwyp82l/publish")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=).with(nil)
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"id":"clfq6dinn000yl70fgwwyp82l","publishedEmailMessageId":"clz2p5q8r0066kqz3chifkr56"}')

      result = described_class.publish(id: "clfq6dinn000yl70fgwwyp82l")
      expect(result).to eq({ "id" => "clfq6dinn000yl70fgwwyp82l", "publishedEmailMessageId" => "clz2p5q8r0066kqz3chifkr56" })
    end
  end

  describe ".send" do
    let(:id) { "clfq6dinn000yl70fgwwyp82l" }
    let(:email) { "test@example.com" }
    let(:add_to_audience) { true }
    let(:data_variables) { { name: "Dan" } }
    let(:attachments) { [{ filename: "file.txt", content: "abc", content_type: "text/plain" }] }
    let(:transformed_attachments) { [{ filename: "file.txt", content: "abc", contentType: "text/plain" }] }

    it "makes a POST request to send a transactional email with all params" do
      expected_body = {
        transactionalId: id,
        email: email,
        addToAudience: add_to_audience,
        dataVariables: data_variables,
        attachments: transformed_attachments
      }

      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=) do |body|
          expect(JSON.parse(body)).to eq(JSON.parse(expected_body.to_json))
        end
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"success":true}')

      result = described_class.send(
        id: id,
        email: email,
        add_to_audience: add_to_audience,
        data_variables: data_variables,
        attachments: attachments
      )
      expect(result).to eq({ "success" => true })
    end

    it "transforms attachment content_type to contentType" do
      expected_body = {
        transactionalId: id,
        email: email,
        addToAudience: add_to_audience,
        dataVariables: data_variables,
        attachments: transformed_attachments
      }

      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=) do |body|
          expect(JSON.parse(body)).to eq(JSON.parse(expected_body.to_json))
        end
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"success":true}')

      result = described_class.send(
        id: id,
        email: email,
        add_to_audience: add_to_audience,
        data_variables: data_variables,
        attachments: attachments
      )
      expect(result).to eq({ "success" => true })
    end

    it "makes a POST request with minimal required params" do
      expected_body = {
        transactionalId: id,
        email: email,
        addToAudience: false,
        dataVariables: {},
        attachments: []
      }

      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional")
        expect(req).to receive(:headers=).with(default_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=) do |body|
          expect(JSON.parse(body)).to eq(JSON.parse(expected_body.to_json))
        end
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"success":true}')

      result = described_class.send(
        id: id,
        email: email
      )
      expect(result).to eq({ "success" => true })
    end

    it "includes custom headers merged with default headers" do
      idempotency_key = "test-key-123"
      custom_headers = { "Idempotency-Key" => idempotency_key }
      expected_headers = default_headers.merge(custom_headers)
      expected_body = {
        transactionalId: id,
        email: email,
        addToAudience: false,
        dataVariables: {},
        attachments: []
      }

      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional")
        expect(req).to receive(:headers=).with(expected_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=) do |body|
          expect(JSON.parse(body)).to eq(JSON.parse(expected_body.to_json))
        end
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"success":true}')

      result = described_class.send(
        id: id,
        email: email,
        headers: custom_headers
      )
      expect(result).to eq({ "success" => true })
    end

    it "allows custom headers to override default headers" do
      custom_content_type = "application/xml"
      custom_headers = { "Content-Type" => custom_content_type }
      expected_headers = default_headers.merge(custom_headers)
      expected_body = {
        transactionalId: id,
        email: email,
        addToAudience: false,
        dataVariables: {},
        attachments: []
      }

      expect(connection).to receive(:send).with(:post) do |&block|
        req = double("req")
        expect(req).to receive(:url).with("v1/transactional")
        expect(req).to receive(:headers=).with(expected_headers)
        expect(req).to receive(:params=).with({})
        expect(req).to receive(:body=) do |body|
          expect(JSON.parse(body)).to eq(JSON.parse(expected_body.to_json))
        end
        block.call(req)
        response
      end

      allow(response).to receive(:status).and_return(200)
      allow(response).to receive(:body).and_return('{"success":true}')

      result = described_class.send(
        id: id,
        email: email,
        headers: custom_headers
      )
      expect(result).to eq({ "success" => true })
    end
  end
end 