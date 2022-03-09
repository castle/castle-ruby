# frozen_string_literal: true

module Castle
  module Core
    # parses api response
    module ProcessResponse
      RESPONSE_ERRORS = {
        400 => Castle::BadRequestError,
        401 => Castle::UnauthorizedError,
        403 => Castle::ForbiddenError,
        404 => Castle::NotFoundError,
        419 => Castle::UserUnauthorizedError
      }.freeze

      INVALID_REQUEST_TOKEN = 'invalid_request_token'

      class << self
        # @param response [Response]
        # @param config [Castle::Configuration, Castle::SingletonConfiguration, nil]
        # @return [Hash]
        def call(response, config = nil)
          verify!(response)

          Castle::Logger.call('response:', response.body.to_s, config)

          return {} if response.body.nil? || response.body.empty?

          begin
            JSON.parse(response.body, symbolize_names: true)
          rescue JSON::ParserError
            raise Castle::ApiError, 'Invalid response from Castle API'
          end
        end

        def verify!(response)
          return if response.code.to_i.between?(200, 299)

          raise Castle::InternalServerError if response.code.to_i.between?(500, 599)

          raise error422(response) if response.code.to_i == 422

          error = RESPONSE_ERRORS.fetch(response.code.to_i, Castle::ApiError)

          raise error
        end

        def error422(response)
          if response.body
            begin
              parsed_body = JSON.parse(response.body, symbolize_names: true)
              if parsed_body.is_a?(Hash) && parsed_body[:type] == INVALID_REQUEST_TOKEN
                return Castle::InvalidRequestTokenError
              end
            rescue JSON::ParserError
            end
          end

          Castle::InvalidParametersError
        end
      end
    end
  end
end
