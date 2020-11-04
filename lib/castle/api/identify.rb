# frozen_string_literal: true

module Castle
  module API
    module Identify
      class << self
        # @param context [Hash]
        # @param options [Hash]
        def call(context, options = {})
          Castle::API.call(
            Castle::Commands::Identify.new(context).build(options),
            {},
            options[:http]
          )
        end
      end
    end
  end
end
