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
        419 => Castle::UserUnauthorizedError,
        422 => Castle::InvalidParametersError
      }.freeze

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

          error = RESPONSE_ERRORS.fetch(response.code.to_i, Castle::ApiError)
          raise error, response[:message]
        end
      end
    end
  end
end
