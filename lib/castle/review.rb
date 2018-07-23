# frozen_string_literal: true

module Castle
  class Review
    def self.retrieve(review_id)
      Castle::API.request(
        Castle::Commands::Review.build(review_id)
      )
    end
  end
end
