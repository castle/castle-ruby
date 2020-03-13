# frozen_string_literal: true

module Castle
  # formats header name
  class HeaderFormatter
    # @param header [String]
    # @return [String]
    def call(header)
      header.to_s.gsub(/^HTTP(?:_|-)/i, '').split(/_|-/).map(&:capitalize).join('-')
    end
  end
end
