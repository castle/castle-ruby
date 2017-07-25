# frozen_string_literal: true

module Castle
  module Commands
    class Identify
      def initialize(context)
        @context_merger = ContextMerger.new(context)
      end

      def build(user_id, options = {})
        raise Castle::InvalidParametersError if user_id.nil? || user_id.to_s.empty?
        request_args = {
          user_id: user_id,
          context: build_context(options[:context])
        }
        request_args[:active] = true if options.key?(:active) && options[:active]
        request_args[:traits] = options[:traits] if options.key?(:traits)

        Castle::Command.new('identify', request_args, :post)
      end

      private

      def build_context(request_context)
        @context_merger.call(request_context || {})
      end
    end
  end
end
