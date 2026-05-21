# frozen_string_literal: true

module LoopsSdk
  class Campaigns < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/campaigns", params: { perPage: perPage, cursor: cursor })
      end

      def create(name:)
        make_request(method: :post, path: "v1/campaigns", body: { name: name })
      end

      def get(campaign_id:)
        make_request(method: :get, path: "v1/campaigns/#{campaign_id}")
      end

      def update(campaign_id:, name:)
        make_request(method: :post, path: "v1/campaigns/#{campaign_id}", body: { name: name })
      end
    end
  end
end
