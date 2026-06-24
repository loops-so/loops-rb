# frozen_string_literal: true

module LoopsSdk
  class Campaigns < Base
    class << self
      def list(perPage: 20, cursor: nil)
        make_request(method: :get, path: "v1/campaigns", params: { perPage: perPage, cursor: cursor })
      end

      def create(name:, campaign_group_id: nil, mailing_list_id: nil, audience_segment_id: nil, audience_filter: nil, scheduling: nil)
        body = {
          name: name,
          campaignGroupId: campaign_group_id,
          mailingListId: mailing_list_id,
          audienceSegmentId: audience_segment_id,
          audienceFilter: audience_filter,
          scheduling: scheduling
        }.compact
        make_request(method: :post, path: "v1/campaigns", body: body)
      end

      def get(campaign_id:)
        make_request(method: :get, path: "v1/campaigns/#{campaign_id}")
      end

      def update(campaign_id:, name: nil, campaign_group_id: nil, mailing_list_id: nil, audience_segment_id: nil, audience_filter: nil, scheduling: nil)
        body = {
          name: name,
          campaignGroupId: campaign_group_id,
          mailingListId: mailing_list_id,
          audienceSegmentId: audience_segment_id,
          audienceFilter: audience_filter,
          scheduling: scheduling
        }.compact
        make_request(method: :post, path: "v1/campaigns/#{campaign_id}", body: body)
      end
    end
  end
end
