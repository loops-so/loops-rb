# frozen_string_literal: true

module LoopsSdk
  class Transactional < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/transactional-emails", params: { perPage: perPage, cursor: cursor })
      end

      def create(name:, transactional_group_id: nil)
        body = { name: name, transactionalGroupId: transactional_group_id }.compact
        make_request(method: :post, path: "v1/transactional-emails", body: body)
      end

      def get(id:)
        make_request(method: :get, path: "v1/transactional-emails/#{id}")
      end

      def update(id:, name: nil, transactional_group_id: nil)
        body = { name: name, transactionalGroupId: transactional_group_id }.compact
        make_request(method: :post, path: "v1/transactional-emails/#{id}", body: body)
      end

      def ensure_draft(id:)
        make_request(method: :post, path: "v1/transactional-emails/#{id}/draft")
      end

      def publish(id:)
        make_request(method: :post, path: "v1/transactional-emails/#{id}/publish")
      end

      def send(id:, email:, add_to_audience: false, data_variables: {}, attachments: [], headers: {})
        attachments = attachments.map do |attachment|
          attachment.transform_keys { |key| key == :content_type ? :contentType : key }
        end
        email_data = {
          transactionalId: id,
          email: email,
          addToAudience: add_to_audience,
          dataVariables: data_variables,
          attachments: attachments
        }.compact
        make_request(method: :post, path: "v1/transactional", headers: headers, body: email_data)
      end
    end
  end
end
