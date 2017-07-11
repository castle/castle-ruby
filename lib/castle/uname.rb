# frozen_string_literal: true

module Castle
  # fetch uname
  class Uname
    def self.fetch
      `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
    rescue Errno::ENOMEM # couldn't create subprocess
      'uname lookup failed'
    end
  end
end
