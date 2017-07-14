# frozen_string_literal: true

module Castle
  # Get information regarding system
  module System
    class << self
      # Returns hardware name, nodename, operating system release, name and version
      # @example Castle::System.uname #=>
      #   Linux server 3.18.44-vs2.3.7.5-beng #1 SMP Thu Oct 27 14:11:29 BST 2016 x86_64 GNU/Linux
      def uname
        `uname -a 2>/dev/null`.strip if platform =~ /linux|darwin/i
      rescue Errno::ENOMEM # couldn't create subprocess
        'uname lookup failed'
      end

      # Returns current system platform
      # @example Castle::System.platform #=> 'x86_64-pc-linux-gnu'
      def platform
        begin
          require 'rbconfig'
          RbConfig::CONFIG['host'] || RUBY_PLATFORM
        rescue LoadError
          RUBY_PLATFORM
        end.downcase
      end

      # Returns ruby version
      # @example Castle::System.ruby_version #=> '2.4.1-p111 (2017-03-22)'
      def ruby_version
        "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"
      end
    end
  end
end
