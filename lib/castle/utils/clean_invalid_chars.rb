# frozen_string_literal: true

module Castle
  module Utils
    module CleanInvalidChars
      class << self
        def call(arg)
          case arg
          when ::String
            arg.encode('UTF-8', invalid: :replace, undef: :replace)
          when ::Hash
            arg.transform_values { |v| Castle::Utils::CleanInvalidChars.call(v) }
          when ::Array
            arg.map { |el| Castle::Utils::CleanInvalidChars.call(el) }
          else
            arg
          end
        end
      end
    end
  end
end
