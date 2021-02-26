# frozen_string_literal: true

module Castle
  # this module uses the Connection object
  # and provides start method for persistent connection usage
  # when there is a need of sending multiple requests at once
  module Session
    HTTPS_SCHEME = 'https'

    class << self
      def call(&block)
        return unless block_given?

        Castle::Core::GetConnection.call.start(&block)
      end
    end
  end
end
