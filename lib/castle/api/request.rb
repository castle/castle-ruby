# frozen_string_literal: true

module Castle
  module API
    # this class is responsible for making requests to api
    module Request
      # Default headers that we add to passed ones
      DEFAULT_HEADERS = {
        'Content-Type' => 'application/json'
      }.freeze

      private_constant :DEFAULT_HEADERS

      class << self
        def call(command, api_secret, headers)
          Castle::API::Session.call do |http|
            http.request(
              build(
                command,
                headers.merge(DEFAULT_HEADERS),
                api_secret
              )
            )
          end
        end

        def build(command, headers, api_secret)
          request_obj = Net::HTTP.const_get(
            command.method.to_s.capitalize
          ).new("#{Castle.config.url.path}/#{command.path}", headers)

          unless command.method == :get
            request_obj.body = ::Castle::Utils.replace_invalid_characters(
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
