# frozen_string_literal: true

module Castle
  module Core
    # this class is responsible for making requests to api
    module SendRequest
      # Default headers that we add to passed ones
      DEFAULT_HEADERS = {
        'Content-Type' => 'application/json'
      }.freeze

      private_constant :DEFAULT_HEADERS

      class << self
        def call(command, headers, http = nil, config = Castle.config)
          (http || Castle::Core::GetConnection.call).request(
            build(
              command,
              headers.merge(DEFAULT_HEADERS),
              config
            )
          )
        end

        def build(command, headers, config = Castle.config)
          url = "#{config.base_url.path}/#{command.path}"
          request_obj = Net::HTTP.const_get(command.method.to_s.capitalize).new(url, headers)

          unless command.method == :get
            request_obj.body = ::Castle::Utils::CleanInvalidChars.call(
              command.data
            ).to_json
          end

          Castle::Logger.call("#{url}:", request_obj.body)

          request_obj.basic_auth('', config.api_secret)
          request_obj
        end
      end
    end
  end
end
