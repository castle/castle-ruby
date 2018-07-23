# frozen_string_literal: true

module Castle
  module API
    # generate api request
    module Request
      module Build
        class << self
          def call(command, headers, api_secret)
            request = Net::HTTP.const_get(
              command.method.to_s.capitalize
            ).new("/#{Castle.config.url_prefix}/#{command.path}", headers)

            unless command.method == :get
              request.body = ::Castle::Utils.replace_invalid_characters(
                command.data
              ).to_json
            end

            request.basic_auth('', api_secret)
            request
          end
        end
      end
    end
  end
end
