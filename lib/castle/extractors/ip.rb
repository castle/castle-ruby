# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of ip from the request
    class IP
      def initialize(request)
        @request = request
      end

      def call
        @request.ip
      end
    end
  end
end
