# frozen_string_literal: true

module Castle
  # fetch system data
  class System
    def self.uname
      `uname -a 2>/dev/null`.strip if platform =~ /linux|darwin/i
    rescue Errno::ENOMEM # couldn't create subprocess
      'uname lookup failed'
    end

    def self.platform
      RUBY_PLATFORM
    end

    def self.lang_version
      "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"
    end
  end
end
