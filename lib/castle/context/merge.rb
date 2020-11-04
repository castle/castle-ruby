# frozen_string_literal: true

module Castle
  module Context
    class Merge
      class << self
        def call(initial_context, request_context)
          main_context = Castle::Utils::Clone.call(initial_context)
          Castle::Utils::Merge.call(main_context, request_context || {})
        end
      end
    end
  end
end
