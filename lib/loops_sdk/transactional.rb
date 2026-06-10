# frozen_string_literal: true

module LoopsSdk
  class Transactional < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/transactional-emails", params: { perPage: perPage, cursor: cursor })
      end

      def create(name:)
        make_request(method: :post, path: "v1/transactional-emails", body: { name: name })
      end

      def get(transactional_id:)
        make_request(method: :get, path: "v1/transactional-emails/#{transactional_id}")
      end

      def update(transactional_id:, name:)
        make_request(method: :post, path: "v1/transactional-emails/#{transactional_id}", body: { name: name })
      end

      def ensure_draft(transactional_id:)
        make_request(method: :post, path: "v1/transactional-emails/#{transactional_id}/draft")
      end

      def publish(transactional_id:)
        make_request(method: :post, path: "v1/transactional-emails/#{transactional_id}/publish")
      end

      def send(transactional_id:, email:, add_to_audience: false, data_variables: {}, attachments: [], headers: {})
        attachments = attachments.map do |attachment|
          attachment.transform_keys { |key| key == :content_type ? :contentType : key }
        end
        email_data = {
          transactionalId: transactional_id,
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
