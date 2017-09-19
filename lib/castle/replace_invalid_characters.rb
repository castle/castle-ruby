# frozen_string_literal: true

module Castle
  class ReplaceInvalidCharacters
    def self.call(hash)
      return hash unless hash.is_a?(Hash)
      hash.each_with_object({}) do |(k, v), h|
        h[k] = if v.is_a?(Hash)
                 call(v)
               elsif v.is_a?(String)
                 v.encode('UTF-8', invalid: :replace, undef: :replace)
               else
                 v
               end
      end
    end
  end
end
