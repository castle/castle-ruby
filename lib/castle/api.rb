# frozen_string_literal: true

module Castle
  # this class is responsible for making requests to api
  module API
    # Errors we handle internally
    HANDLED_ERRORS = [
      Timeout::Error,
      Errno::EINVAL,
      Errno::ECONNRESET,
      EOFError,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError
    ].freeze

    private_constant :HANDLED_ERRORS

    class << self
      def request(command, headers = {})
        raise Castle::ConfigurationError, 'configuration is not valid' unless Castle.config.valid?

        begin
          Castle::API::Response.call(
            Castle::API::Request.call(
              command,
              Castle.config.api_secret,
              headers
            )
          )
        rescue *HANDLED_ERRORS => e
          # @note We need to initialize the error, as the original error is a cause for this
          # custom exception. If we would do it the default Ruby way, the original error
          # would get converted into a string
          raise Castle::RequestError.new(e) # rubocop:disable Style/RaiseArgs
        end
      end
    end
  end
end
