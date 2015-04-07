class Castle::Error < Exception; end

class Castle::RequestError < Castle::Error; end
class Castle::SecurityError < Castle::Error; end
class Castle::ConfigurationError < Castle::Error; end

class Castle::ApiError < Castle::Error; end

class Castle::BadRequestError < Castle::ApiError; end
class Castle::ForbiddenError < Castle::ApiError; end
class Castle::NotFoundError < Castle::ApiError; end
class Castle::UserUnauthorizedError < Castle::ApiError; end
class Castle::InvalidParametersError < Castle::ApiError; end

class Castle::UnauthorizedError < Castle::ApiError; end
class Castle::ChallengeRequiredError < Castle::ApiError; end
