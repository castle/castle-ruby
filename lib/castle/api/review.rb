# frozen_string_literal: true

module Castle
  module API
    module Review
      class << self
        # @param review_id [String]
        # @param options [Hash]
        # return [Hash]
        def call(review_id, options = {})
          Castle::API.call(
            Castle::Commands::Review.new.build(review_id),
            {},
            options[:http]
          )
        end
      end
    end
  end
end
