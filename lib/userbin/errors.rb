class Userbin::Error < Exception; end
class Userbin::NotFoundError < Userbin::Error; end
class Userbin::Forbidden < Userbin::Error; end
class Userbin::UserUnauthorizedError < Userbin::Error; end
class Userbin::SecurityError < Userbin::Error; end
class Userbin::ConfigurationError < Userbin::Error; end
