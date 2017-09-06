# frozen_string_literal: true

module Castle
  # parses api response
  class Response
    RESPONSE_ERRORS = {
      400 => Castle::BadRequestError,
      401 => Castle::UnauthorizedError,
      403 => Castle::ForbiddenError,
      404 => Castle::NotFoundError,
      419 => Castle::UserUnauthorizedError,
      422 => Castle::InvalidParametersError
    }.freeze

    def initialize(response)
      @response = response
      verify_response_code
    end

    def parse
      response_body = @response.body

      return {} if response_body.nil? || response_body.empty?

      begin
        JSON.parse(response_body, symbolize_names: true)
      rescue JSON::ParserError
        raise Castle::ApiError, 'Invalid response from Castle API'
      end
    end

    private

    def verify_response_code
      response_code = @response.code.to_i

      return if response_code.between?(200, 299)

      raise Castle::InternalServerError if response_code.between?(500, 599)

      error = RESPONSE_ERRORS.fetch(response_code, Castle::ApiError)
      raise error, @response[:message]
    end
  end
end
