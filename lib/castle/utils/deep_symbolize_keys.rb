# frozen_string_literal: true

module Castle
  module Utils
    module DeepSymbolizeKeys
      class << self
        # Returns a new hash with all keys converted to symbols, as long as
        # they respond to +to_sym+. This includes the keys from the root hash
        # and from all nested hashes and arrays.
        #
        #   hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
        #
        #   Castle::Hash.deep_symbolize_keys(hash)
        #   # => {:person=>{:name=>"Rob", :age=>"28"}}
        def call(object, &block)
          case object
          when Hash
            object.each_with_object({}) do |(key, value), result|
              result[key.to_sym] = Castle::Utils::DeepSymbolizeKeys.call(value, &block)
            end
          when Array
            object.map { |e| Castle::Utils::DeepSymbolizeKeys.call(e, &block) }
          else
            object
          end
        end

        def call!(object, &block)
          case object
          when Hash
            object.each_key do |key|
              value = object.delete(key)
              object[key.to_sym] = Castle::Utils::DeepSymbolizeKeys.call!(value, &block)
            end
            object
          when Array
            object.map! { |e| Castle::Utils::DeepSymbolizeKeys.call!(e, &block) }
          else
            object
          end
        end
      end
    end
  end
end
