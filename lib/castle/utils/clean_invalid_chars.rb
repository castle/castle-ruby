# frozen_string_literal: true

module Castle
  module Utils
    module CleanInvalidChars
      class << self
        def call(arg)
          if arg.is_a?(::String)
            arg.encode('UTF-8', invalid: :replace, undef: :replace)
          elsif arg.is_a?(::Hash)
            arg.each_with_object({}) do |(k, v), h|
              h[k] = Castle::Utils::CleanInvalidChars.call(v)
            end
          elsif arg.is_a?(::Array)
            arg.map { |el| Castle::Utils::CleanInvalidChars.call(el) }
          else
            arg
          end
        end
      end
    end
  end
end
