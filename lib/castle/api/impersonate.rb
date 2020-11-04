# frozen_string_literal: true

module Castle
  module API
    module Impersonate
      class << self
        # @param context [Hash]
        # @param options [Hash]
        def call(context, options = {})
          Castle::API.call(
            Castle::Commands::Impersonate.new(context).build(options),
            {},
            options[:http]
          ).tap do |response|
            raise Castle::ImpersonationFailed unless response[:success]
          end
        end
      end
    end
  end
end
