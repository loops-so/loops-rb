# frozen_string_literal: true

module LoopsSdk
  class TransactionalGroups < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/transactional-groups", params: { perPage: perPage, cursor: cursor })
      end

      def create(name:, description: nil)
        body = { name: name, description: description }.compact
        make_request(method: :post, path: "v1/transactional-groups", body: body)
      end

      def get(transactional_group_id:)
        make_request(method: :get, path: "v1/transactional-groups/#{transactional_group_id}")
      end

      def update(transactional_group_id:, name: nil, description: nil)
        body = { name: name, description: description }.compact
        make_request(method: :post, path: "v1/transactional-groups/#{transactional_group_id}", body: body)
      end
    end
  end
end
