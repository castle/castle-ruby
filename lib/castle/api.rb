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
      # @param command [String]
      # @param headers [Hash]
      # @param http [Net::HTTP]
      # @return [Hash]
      def call(command, headers = {}, http = nil, config: Castle.config)
        Castle::Core::ProcessResponse.call(
          send_request(command, headers, http, config: config)
        )
      end

      private

      # @param command [String]
      # @param headers [Hash]
      # @param http [Net::HTTP]
      def send_request(command, headers = {}, http = nil, config: Castle.config)
        raise Castle::ConfigurationError, 'configuration is not valid' unless config.valid?

        begin
          Castle::Core::SendRequest.call(
            command,
            headers,
            http,
            config: config
          )
        rescue *HANDLED_ERRORS => e
          # @note We need to initialize the error, as the original error is a cause for this
          # custom exception. If we would do it the default Ruby way, the original error
          # would get converted into a string
          # rubocop:disable Style/RaiseArgs
          raise Castle::RequestError.new(e)
          # rubocop:enable Style/RaiseArgs
        end
      end
    end
  end
end
