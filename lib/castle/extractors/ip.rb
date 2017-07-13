# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of ip from the request
    class Ip
      def initialize(request)
        @request = request
      end

      def extract
        @request.ip
      end
    end
  end
end
