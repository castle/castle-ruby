# frozen_string_literal: true

module Castle
  module Options
    # merges initial request options with request option
    class Merge
      class << self
        # @param initial_options [Hash]
        # @param request_options [Hash]
        def call(initial_options, request_options)
          main_options = Castle::Utils::Clone.call(initial_options)
          Castle::Utils::Merge.call(main_options, request_options || {})
        end
      end
    end
  end
end
