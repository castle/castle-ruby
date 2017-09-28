# frozen_string_literal: true

module Castle
  class Review
    def self.retrieve(review_id)
      command = Castle::Commands::Review.new({}).build(review_id)

      API.new.request(command)
    end
  end
end
