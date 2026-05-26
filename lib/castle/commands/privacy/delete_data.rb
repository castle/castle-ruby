# frozen_string_literal: true

module Castle
  module Commands
    module Privacy
      # Builds the command for DELETE /v1/privacy/users — GDPR Article 17 (right to be forgotten).
      class DeleteData
        class << self
          # @param options [Hash] must include :identifier and :identifier_type ($id or $email)
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[identifier identifier_type])

            Castle::Command.new('privacy/users', options, :delete)
          end
        end
      end
    end
  end
end
