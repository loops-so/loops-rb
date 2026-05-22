# frozen_string_literal: true

module LoopsSdk
  class EmailMessages < Base
    class << self
      def get(email_message_id:)
        make_request(method: :get, path: "v1/email-messages/#{email_message_id}")
      end

      def update(email_message_id:, expected_revision_id: nil, subject: nil, preview_text: nil, from_name: nil, from_email: nil, reply_to_email: nil, lmx: nil)
        body = {
          expectedRevisionId: expected_revision_id,
          subject: subject,
          previewText: preview_text,
          fromName: from_name,
          fromEmail: from_email,
          replyToEmail: reply_to_email,
          lmx: lmx
        }.compact
        make_request(method: :post, path: "v1/email-messages/#{email_message_id}", body: body)
      end
    end
  end
end
