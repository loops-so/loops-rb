# frozen_string_literal: true

module LoopsSdk
  class Uploads < Base
    SUPPORTED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

    class << self
      def upload(path:, content_type: nil)
        data = File.binread(path)
        content_type ||= detect_content_type(data)
        validate_content_type!(content_type)

        create_response = make_request(
          method: :post,
          path: "v1/uploads",
          body: { contentType: content_type, contentLength: data.bytesize }
        )

        put_to_presigned_url(create_response["presignedUrl"], data, content_type)

        make_request(
          method: :post,
          path: "v1/uploads/#{create_response["emailAssetId"]}/complete"
        )
      end

      private

      def detect_content_type(data)
        if data.start_with?("\xFF\xD8\xFF".b)
          "image/jpeg"
        elsif data.start_with?("\x89PNG\r\n\x1a\n".b)
          "image/png"
        elsif data.start_with?("GIF87a".b, "GIF89a".b)
          "image/gif"
        elsif data.bytesize >= 12 && data[0, 4] == "RIFF".b && data[8, 4] == "WEBP".b
          "image/webp"
        else
          raise ArgumentError,
                "Unable to detect image type. Pass content_type: explicitly. " \
                "Supported types: #{SUPPORTED_CONTENT_TYPES.join(', ')}."
        end
      end

      def validate_content_type!(content_type)
        return if SUPPORTED_CONTENT_TYPES.include?(content_type)

        raise ArgumentError,
              "Unsupported content_type: #{content_type}. " \
              "Supported types: #{SUPPORTED_CONTENT_TYPES.join(', ')}."
      end

      def put_to_presigned_url(url, data, content_type)
        response = Faraday.put(url) do |req|
          req.headers["Content-Type"] = content_type
          req.headers["Content-Length"] = data.bytesize.to_s
          req.body = data
        end

        return if response.success?

        raise APIError.new(response.status, response.body)
      end
    end
  end
end
