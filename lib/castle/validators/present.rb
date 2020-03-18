# frozen_string_literal: true

module Castle
  module Validators
    class Present
      class << self
        def call(options, keys)
          keys.each do |key|
            next unless options[key].to_s.empty?

            raise Castle::InvalidParametersError, "#{key} is missing or empty"
          end
        end
      end
    end
  end
end
