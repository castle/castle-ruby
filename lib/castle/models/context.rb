module Castle
  class Context < Model
    def user_agent
      if attributes['user_agent']
        Castle::UserAgent.new(attributes['user_agent'])
      end
    end

    def location
      if attributes['location']
        Castle::Location.new(attributes['location'])
      end
    end
  end

  class UserAgent < Model; end
  class Location < Model; end
end
