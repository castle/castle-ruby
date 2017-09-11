# frozen_string_literal: true

module Castle
  module Commands
    class Identify
      def initialize(context)
        @context_merger = ContextMerger.new(context)
      end

      def build(options = {})
        user_id = options[:user_id]
        raise Castle::InvalidParametersError if user_id.nil? || user_id.to_s.empty?

        if options[:context] && options[:context].key?(:active)
          unless [true, false].include?(options[:context][:active])
            options[:context].delete(:active)
          end
        end

        args = {
          user_id: user_id,
          context: build_context(options[:context])
        }

        args[:traits] = options[:traits] if options.key?(:traits)

        Castle::Command.new('identify', args, :post)
      end

      private

      def build_context(request_context)
        @context_merger.call(request_context || {})
      end
    end
  end
end
