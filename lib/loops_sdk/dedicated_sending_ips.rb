# frozen_string_literal: true

module LoopsSdk
  class DedicatedSendingIps < Base
    class << self
      def list
        make_request(method: :get, path: "v1/dedicated-sending-ips")
      end
    end
  end
end
