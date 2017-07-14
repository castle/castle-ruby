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

    def prepare(cookie_id, ip, castle_headers)
      @headers.merge!(
        'X-Castle-Cookie-Id' => cookie_id,
        'X-Castle-Ip' => ip,
        'X-Castle-Headers' => castle_headers,
        'X-Castle-Client-User-Agent' => JSON.generate(client_user_agent),
        'X-Castle-Source' => @config.source_header
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
