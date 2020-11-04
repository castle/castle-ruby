# frozen_string_literal: true

module Castle
  module Context
    module Prepare
      class << self
        def call(request, options = {})
          default_context = Castle::Context::GetDefault.new(request, options[:cookies]).call
          context = Castle::Context::Merge.call(default_context, options[:context])
          context
        end
      end
    end
  end
end
