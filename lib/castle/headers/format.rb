# frozen_string_literal: true

module Castle
  module Headers
    # formats header name
    class Format
      class << self
        # @param header [String]
        # @return [String]
        def call(header)
          format(header.to_s.gsub(/^HTTP(?:_|-)/i, ''))
        end

        private

        # @param header [String]
        # @return [String]
        def format(header)
          header.split(/_|-/).map(&:capitalize).join('-')
        end
      end
    end
  end
end
