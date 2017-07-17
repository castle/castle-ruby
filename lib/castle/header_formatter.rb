# frozen_string_literal: true

module Castle
  class HeaderFormatter
    def call(header)
      header.gsub(/^HTTP(?:_|-)/i, '').split(/_|-/).map(&:capitalize).join('-')
    end
  end
end
