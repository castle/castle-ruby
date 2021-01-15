# frozen_string_literal: true

module Castle
  module Utils
    # Code borrowed from ActiveSupport
    class SecureCompare
      class << self
        # @param str_a [String] first string to be compared
        # @param str_b [String] second string to be compared
        def call(str_a, str_b)
          return false unless str_a.bytesize == str_b.bytesize

          l = str_a.unpack "C#{str_a.bytesize}"

          res = 0
          str_b.each_byte { |byte| res |= byte ^ l.shift }
          res.zero?
        end
      end
    end
  end
end
