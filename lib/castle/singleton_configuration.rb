# frozen_string_literal: true

require 'singleton'

module Castle
  class SingletonConfiguration < Configuration
    include Singleton
  end
end
