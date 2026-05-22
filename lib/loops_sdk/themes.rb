# frozen_string_literal: true

module LoopsSdk
  class Themes < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/themes", params: { perPage: perPage, cursor: cursor })
      end

      def get(theme_id:)
        make_request(method: :get, path: "v1/themes/#{theme_id}")
      end
    end
  end
end
