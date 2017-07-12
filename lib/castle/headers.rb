# frozen_string_literal: true

module Castle
  # setups headers for requests
  class Headers
    def initialize
      @config = Castle.config
      @uname = Castle::Uname
      @headers = {}
    end

    def prepare(cookie_id, ip, headers)
      @headers = {
        'Content-Type' => 'application/json',
        'X-Castle-Cookie-Id' => cookie_id,
        'X-Castle-Ip' => ip,
        'X-Castle-Headers' => headers,
        'X-Castle-Client-User-Agent' => JSON.generate(client_user_agent),
        'X-Castle-Source' => @config.source_header,
        'User-Agent' => "Castle/v1 RubyBindings/#{Castle::VERSION}"
      }
      @headers.delete_if { |_k, header_value| header_value.nil? }
    end

    private

    def client_user_agent
      version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"
      {
        bindings_version: Castle::VERSION,
        lang: 'ruby',
        lang_version: version,
        platform: RUBY_PLATFORM,
        publisher: 'castle',
        uname: @uname.fetch
      }
    end
  end
end
