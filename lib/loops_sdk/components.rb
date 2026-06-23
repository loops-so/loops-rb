# frozen_string_literal: true

module LoopsSdk
  class Components < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/components", params: { perPage: perPage, cursor: cursor })
      end

      def get(id:)
        make_request(method: :get, path: "v1/components/#{id}")
      end
    end
  end
end
