# frozen_string_literal: true

module Castle
  module Options
    class Merge
      class << self
        def call(initial_options, request_options)
          main_options = Castle::Utils::Clone.call(initial_options)
          Castle::Utils::Merge.call(main_options, request_options || {})
        end
      end
    end
  end
end
