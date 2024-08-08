# frozen_string_literal: true

module Castle
  # general error
  class Error < RuntimeError
  end

  # Raised when anything is wrong with the request (any unhappy path)
  # This error indicates that either we would wait too long for a response or something
  # else happened somewhere in the middle and we weren't able to get the results
  class RequestError < Castle::Error
    attr_reader :reason

    # @param reason [Exception] the core exception that causes this error
    def initialize(reason)
      @reason = reason
    end
  end

  # security error
  class SecurityError < Castle::Error
  end

  # wrong configuration error
  class ConfigurationError < Castle::Error
  end

  # error returned by api
  class ApiError < Castle::Error
  end

  # webhook signature verification error
  class WebhookVerificationError < Castle::Error
  end

  # api error bad request 400
  class BadRequestError < Castle::ApiError
  end

  # api error forbidden 403
  class ForbiddenError < Castle::ApiError
  end

  # api error not found 404
  class NotFoundError < Castle::ApiError
  end

  # api error user unauthorized 419
  class UserUnauthorizedError < Castle::ApiError
  end

  # api error invalid param 422
  class InvalidParametersError < Castle::ApiError
  end

  # api error invalid param 422 (invalid token)
  class InvalidRequestTokenError < Castle::ApiError
  end

  # api error unauthorized 401
  class UnauthorizedError < Castle::ApiError
  end

  # api error too many requests 429
  class RateLimitError < Castle::ApiError
  end

  # all internal server errors
  class InternalServerError < Castle::ApiError
  end

  # impersonation command failed
  class ImpersonationFailed < Castle::ApiError
  end
end
