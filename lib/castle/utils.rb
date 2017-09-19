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
    end
  end
end
