module Userbin

  Callback = Struct.new(:pattern, :block) do; end

  class Events
    def self.on(*names, &block)
      pattern = Regexp.union(names.empty? ? TYPE_LIST.to_a : names)
      callbacks.each do |callback|
        if pattern == callback.pattern
          callbacks.delete(callback)
          callbacks << Userbin::Callback.new(pattern, block)
          return
        end
      end
      callbacks << Userbin::Callback.new(pattern, block)
    end

    def self.trigger(raw_event)
      event = Userbin::Event.new(raw_event)
      callbacks.each do |callback|
        if event.type =~ callback.pattern
          object = case event['type']
          when /^user\./
            Userbin::User.new(event.object)
          else
            event.object
          end
          model = event.instance_exec object, &callback.block
        end
      end
    end

    private

    def self.callbacks
      @callbacks ||= []
    end
  end

end
