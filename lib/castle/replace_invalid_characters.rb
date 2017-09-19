# frozen_string_literal: true

module Castle
  class ReplaceInvalidCharacters
    def self.call(arg)
      if arg.is_a?(String)
        arg.encode('UTF-8', invalid: :replace, undef: :replace)
      elsif arg.is_a?(Hash)
        arg.each_with_object({}) do |(k, v), h|
          h[k] = call(v)
        end
      else
        arg
      end
    end
  end
end
