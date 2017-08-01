# frozen_string_literal: true

module Castle
  # setups headers for requests
  class Headers
    def initialize
      @config = Castle.config
      @headers = {
        'Content-Type' => 'application/json',
        'User-Agent' => "Castle/v1 RubyBindings/#{Castle::VERSION}"
      }
    end

    def prepare(client_id, ip, request_headers)
      @headers.merge!(
        'X-Castle-Client-Id' => client_id,
        'X-Castle-Ip' => ip,
        'X-Castle-Headers' => request_headers ? JSON.generate(request_headers) : nil,
        'X-Castle-Client-User-Agent' => JSON.generate(client_user_agent)
      )
      @headers.delete_if { |_k, header_value| header_value.nil? }
      @headers
    end

    private

    def client_user_agent
      {
        bindings_version: Castle::VERSION,
        lang: 'ruby',
        lang_version: Castle::System.ruby_version,
        platform: Castle::System.platform,
        publisher: 'castle',
        uname: Castle::System.uname
      }
    end
  end
end
