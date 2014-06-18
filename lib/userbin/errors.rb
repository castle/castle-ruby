class Userbin::Error < Exception; end

class Userbin::RequestError < Userbin::Error; end
class Userbin::SecurityError < Userbin::Error; end
class Userbin::ConfigurationError < Userbin::Error; end

class Userbin::ApiError < Userbin::Error; end

class Userbin::BadRequest < Userbin::ApiError; end
class Userbin::UnauthorizedError < Userbin::ApiError; end
class Userbin::ForbiddenError < Userbin::ApiError; end
class Userbin::NotFoundError < Userbin::ApiError; end
class Userbin::UserUnauthorizedError < Userbin::ApiError; end
class Userbin::InvalidParametersError < Userbin::ApiError; end
