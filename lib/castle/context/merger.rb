# frozen_string_literal: true

module Castle
  module Context
    class Merger
      class << self
        def call(initial_context, request_context)
          main_context = Castle::Utils::Cloner.call(initial_context)
          Castle::Utils::Merger.call(main_context, request_context || {})
        end
      end
    end
  end
end
