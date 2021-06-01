# frozen_string_literal: true

module Castle
  module Context
    class GetDefault
      def initialize(request, cookies = nil)
        @pre_headers = Castle::Headers::Filter.new(request).call
        @cookies = cookies || request.cookies
        @request = request
      end

      def call
        { active: true, library: { name: 'castle-rb', version: Castle::VERSION } }
      end
    end
  end
end
