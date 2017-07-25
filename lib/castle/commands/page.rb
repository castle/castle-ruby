# frozen_string_literal: true

module Castle
  module Commands
    class Page
      def initialize(context)
        @context_merger = ContextMerger.new(context)
      end

      def build(name, options = {})
        raise Castle::InvalidParametersError if name.nil? || name.to_s.empty?
        request_args = {
          name: name,
          context: build_context(options[:context])
        }
        request_args[:user_id] = options[:user_id] if options.key?(:user_id)
        request_args[:properties] = options[:properties] if options.key?(:properties)

        Castle::Command.new('page', request_args, :post)
      end

      private

      def build_context(request_context)
        @context_merger.call(request_context || {})
      end
    end
  end
end
