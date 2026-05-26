# frozen_string_literal: true

module Castle
  module Commands
    module Privacy
      # Builds the command for POST /v1/privacy/users — GDPR Article 15 (right of access).
      class RequestData
        class << self
          # @param options [Hash] must include :identifier and :identifier_type ($id or $email)
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[identifier identifier_type])

            Castle::Command.new('privacy/users', options, :post)
          end
        end
      end
    end
  end
end
