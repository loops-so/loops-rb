# frozen_string_literal: true

module LoopsSdk
  class AudienceSegments < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/audience-segments", params: { perPage: perPage, cursor: cursor })
      end

      def get(id:)
        make_request(method: :get, path: "v1/audience-segments/#{id}")
      end
    end
  end
end
