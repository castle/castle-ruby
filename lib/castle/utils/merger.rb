# frozen_string_literal: true

module Castle
  module Utils
    class Merger
      def self.call(first, second)
        first_s = Castle::Utils.deep_symbolize_keys(first)
        second_s = Castle::Utils.deep_symbolize_keys(second)

        second_s.each do |name, value|
          if value.nil?
            first_s.delete(name)
          elsif value.is_a?(Hash) && first_s[name].is_a?(Hash)
            first_s[name] = call(first_s[name], value)
          else
            first_s[name] = value
          end
        end
        first_s
      end
    end
  end
end
