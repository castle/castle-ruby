# frozen_string_literal: true

module Castle
  module Commands
    class Review
      def initialize(_context)
      end

      def build(review_id)
        raise Castle::InvalidParametersError if review_id.nil? || review_id.to_s.empty?

        Castle::Command.new("reviews/#{review_id}", nil, :get)
      end
    end
  end
end
