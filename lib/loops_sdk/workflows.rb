# frozen_string_literal: true

module LoopsSdk
  class Workflows < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/workflows", params: { perPage: perPage, cursor: cursor })
      end

      def get(workflow_id:)
        make_request(method: :get, path: "v1/workflows/#{workflow_id}")
      end

      def get_node(workflow_id:, node_id:)
        make_request(method: :get, path: "v1/workflows/#{workflow_id}/nodes/#{node_id}")
      end
    end
  end
end
