# frozen_string_literal: true

module LoopsSdk
  class EmailMessages < Base
    class << self
      def get(id:)
        make_request(method: :get, path: "v1/email-messages/#{id}")
      end

      def update(
        id:,
        expected_revision_id: nil,
        subject: nil,
        preview_text: nil,
        from_name: nil,
        from_email: nil,
        reply_to_email: nil,
        cc_email: nil,
        bcc_email: nil,
        language_code: nil,
        email_format: nil,
        lmx: nil,
        contact_properties_fallbacks: nil,
        event_properties_fallbacks: nil,
        data_variables_fallbacks: nil
      )
        body = {
          expectedRevisionId: expected_revision_id,
          subject: subject,
          previewText: preview_text,
          fromName: from_name,
          fromEmail: from_email,
          replyToEmail: reply_to_email,
          ccEmail: cc_email,
          bccEmail: bcc_email,
          languageCode: language_code,
          emailFormat: email_format,
          lmx: lmx,
          contactPropertiesFallbacks: contact_properties_fallbacks,
          eventPropertiesFallbacks: event_properties_fallbacks,
          dataVariablesFallbacks: data_variables_fallbacks
        }.compact
        make_request(method: :post, path: "v1/email-messages/#{id}", body: body)
      end

      def preview(id:, emails:, contact_properties: nil, event_properties: nil, data_variables: nil)
        body = {
          emails: emails,
          contactProperties: contact_properties,
          eventProperties: event_properties,
          dataVariables: data_variables
        }.compact
        make_request(method: :post, path: "v1/email-messages/#{id}/preview", body: body)
      end
    end
  end
end
