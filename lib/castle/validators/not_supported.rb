# frozen_string_literal: true

module Castle
  module Validators
    class NotSupported
      class << self
        def call(options, keys)
          keys.each do |key|
            raise Castle::InvalidParametersError, "#{key} is/are not supported in identify calls" if options.key?(key)
          end
        end
      end
    end
  end
end
