# frozen_string_literal: true

module Castle
  module Utils
    class Merger
      def self.call(first, second)
        Castle::Utils.deep_symbolize_keys!(first)
        Castle::Utils.deep_symbolize_keys!(second)

        second.each do |name, value|
          if value.nil?
            first.delete(name)
          elsif value.is_a?(Hash) && first[name].is_a?(Hash)
            call(first[name], value)
          else
            first[name] = value
          end
        end
        first
      end
    end
  end
end
