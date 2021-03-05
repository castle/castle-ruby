# frozen_string_literal: true

module Castle
  module Context
    class GetDefault
      class << self
        def call
          { active: true, library: { name: 'castle-rb', version: Castle::VERSION } }
        end
      end
    end
  end
end
