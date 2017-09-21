# frozen_string_literal: true

module Castle
  module Utils
    class << self
      # Returns a new hash with all keys converted to symbols, as long as
      # they respond to +to_sym+. This includes the keys from the root hash
      # and from all nested hashes and arrays.
      #
      #   hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
      #
      #   Castle::Hash.deep_symbolize_keys(hash)
      #   # => {:person=>{:name=>"Rob", :age=>"28"}}
      def deep_symbolize_keys(object, &block)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[key.to_sym] = deep_symbolize_keys(value, &block)
          end
        when Array
          object.map { |e| deep_symbolize_keys(e, &block) }
        else
          object
        end
      end

      def deep_symbolize_keys!(object, &block)
        case object
        when Hash
          object.keys.each do |key|
            value = object.delete(key)
            object[key.to_sym] = deep_symbolize_keys!(value, &block)
          end
          object
        when Array
          object.map! { |e| deep_symbolize_keys!(e, &block) }
        else
          object
        end
      end

      def replace_invalid_characters(arg)
        if arg.is_a?(::String)
          arg.encode('UTF-8', invalid: :replace, undef: :replace)
        elsif arg.is_a?(::Hash)
          arg.each_with_object({}) { |(k, v), h| h[k] = replace_invalid_characters(v) }
        elsif arg.is_a?(::Array)
          arg.map(&method(:replace_invalid_characters))
        else
          arg
        end
      end
    end
  end
end
