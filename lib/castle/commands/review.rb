# frozen_string_literal: true

module Castle
  module Commands
    # Generates the payload for the GET reviews/#{review_id} request
    class Review
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          Castle::Validators::Present.call(options, %i[review_id])
          Castle::Command.new("reviews/#{options[:review_id]}", nil, :get)
        end
      end
    end
  end
end
