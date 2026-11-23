# frozen_string_literal: true

module LoopsSdk
  class Footers < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/footers", params: { perPage: perPage, cursor: cursor })
      end

      def get(footer_id:)
        make_request(method: :get, path: "v1/footers/#{footer_id}")
      end

      def create(name: nil)
        body = { name: name }.compact
        make_request(method: :post, path: "v1/footers", body: body)
      end

      def update(footer_id:, name: nil, placement: nil)
        body = { name: name, placement: placement }.compact
        make_request(method: :post, path: "v1/footers/#{footer_id}", body: body)
      end

      def delete(footer_id:)
        make_request(method: :delete, path: "v1/footers/#{footer_id}")
      end

      def set_default(footer_id:, existing_emails:)
        make_request(
          method: :post,
          path: "v1/footers/#{footer_id}/set-default",
          body: { existingEmails: existing_emails }
        )
      end

      def get_variant(footer_id:, variant_id:)
        make_request(method: :get, path: "v1/footers/#{footer_id}/variants/#{variant_id}")
      end

      def update_variant(footer_id:, variant_id:, expected_revision_id:, lmx:)
        make_request(
          method: :post,
          path: "v1/footers/#{footer_id}/variants/#{variant_id}",
          body: { expectedRevisionId: expected_revision_id, lmx: lmx }
        )
      end

      def publish_variant(footer_id:, variant_id:, expected_revision_id:)
        make_request(
          method: :post,
          path: "v1/footers/#{footer_id}/variants/#{variant_id}/publish",
          body: { expectedRevisionId: expected_revision_id }
        )
      end
    end
  end
end
