# frozen_string_literal: true

module Castle
  # general error
  class Error < RuntimeError; end
  # request error
  class RequestError < Castle::Error; end
  # security error
  class SecurityError < Castle::Error; end
  # wrong configuration error
  class ConfigurationError < Castle::Error; end
  # error returned by api
  class ApiError < Castle::Error; end

  # api error bad request 400
  class BadRequestError < Castle::ApiError; end
  # api error forbidden 403
  class ForbiddenError < Castle::ApiError; end
  # api error not found 404
  class NotFoundError < Castle::ApiError; end
  # api error user unauthorized 419
  class UserUnauthorizedError < Castle::ApiError; end
  # api error invalid param 422
  class InvalidParametersError < Castle::ApiError; end
  # api error unauthorized 401
  class UnauthorizedError < Castle::ApiError; end
end
