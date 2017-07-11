# frozen_string_literal: true

module Castle
  # setups headers for requests
  class Headers
    def initialize
      @config = Castle.config
      @uname = Castle::Uname
      @headers = {
        'Content-Type' => 'application/json',
        'User-Agent' => "Castle/v1 RubyBindings/#{version}"
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
        bindings_version: version,
        lang: 'ruby',
        lang_version: lang_version,
        platform: RUBY_PLATFORM,
        publisher: 'castle',
        uname: @uname.fetch
      }
    end

    def version
      Castle::VERSION
    end

    def platform
      RUBY_PLATFORM
    end

    def lang_version
      "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"
    end
  end
end
