# frozen_string_literal: true

module LoopsSdk
  class CampaignGroups < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/campaign-groups", params: { perPage: perPage, cursor: cursor })
      end

      def create(name:, description: nil)
        body = { name: name, description: description }.compact
        make_request(method: :post, path: "v1/campaign-groups", body: body)
      end

      def get(id:)
        make_request(method: :get, path: "v1/campaign-groups/#{id}")
      end

      def update(id:, name: nil, description: nil)
        body = { name: name, description: description }.compact
        make_request(method: :post, path: "v1/campaign-groups/#{id}", body: body)
      end
    end
  end
end
