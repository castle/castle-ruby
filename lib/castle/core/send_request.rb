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
        def call(command, api_secret, headers, http = nil)
          (http || Castle::Core::GetConnection.call).request(
            build(
              command,
              headers.merge(DEFAULT_HEADERS),
              api_secret
            )
          )
        end

        def build(command, headers, api_secret)
          request_obj = Net::HTTP.const_get(
            command.method.to_s.capitalize
          ).new("#{Castle.config.base_url.path}/#{command.path}", headers)

          unless command.method == :get
            request_obj.body = ::Castle::Utils::CleanInvalidChars.call(
              command.data
            ).to_json
          end

          request_obj.basic_auth('', api_secret)
          request_obj
        end
      end
    end
  end
end
