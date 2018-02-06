# frozen_string_literal: true

module Castle
  module Commands
    class Review
      def build(review_id)
        Castle::Validators::Present.call({review_id: review_id}, %i[review_id])
        Castle::Command.new("reviews/#{review_id}", nil, :get)
      end
    end
  end
end
