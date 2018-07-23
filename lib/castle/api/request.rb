# frozen_string_literal: true

module Castle
  # this class is responsible for making requests to api
  module API
    module Request
      # Default headers that we add to passed ones
      DEFAULT_HEADERS = {
        'Content-Type' => 'application/json'
      }.freeze

      private_constant :DEFAULT_HEADERS

      class << self
        def call(command, api_secret, headers)
          http.request(
            Castle::API::Request::Build.call(
              command,
              headers.merge(DEFAULT_HEADERS),
              api_secret
            )
          )
        end

        def http
          http = Net::HTTP.new(Castle.config.host, Castle.config.port)
          http.read_timeout = Castle.config.request_timeout / 1000.0
          if Castle.config.port == 443
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end
          http
        end
      end
    end
  end
end
