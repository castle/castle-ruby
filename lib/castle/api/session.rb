# frozen_string_literal: true

module Castle
  module API
    # this class keeps http config object
    # and provides start method for persistent connection usage
    # when there is a need of sending multiple requests at once
    module Session
      HTTPS_SCHEME = 'https'

      class << self
        def call(&block)
          return unless block_given?

          Connection.call.start(&block)
        end
      end
    end
  end
end
