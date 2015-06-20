require 'her'

class Her::Collection
  # Call the overridden to_json in Castle::Model
  def to_json
    self.map { |m| m.to_json }
  end
end

module Castle
  class Model
    include Her::Model
    use_api Castle::API

    def initialize(args = {})
      # allow initializing with id as a string
      args = { id: args } if args.is_a? String
      super(args)
    end

    # Transform model.user.id to model.user_id to allow calls on nested models
    def attributes
      attrs = super
      if attrs['user'] && attrs['user']['id']
        attrs.merge!('user_id' => attrs['user']['id'])
        attrs.delete 'user'
      end
      attrs
    end

    METHODS.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.instance_#{method}(action)
          instance_custom(:#{method}, action)
        end
      RUBY
    end

    def self.instance_custom(method, action)
      #
      # Add method calls to association: user.events.some_method(id, attributes)
      #
      AssociationProxy.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        install_proxy_methods :association, :#{action}
      RUBY
      HasManyAssociation.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{action}(id, attributes={})
          @klass.build({:id => id, :"\#{@parent.singularized_resource_name}_id" => @parent.id}).#{action}(attributes)
        end
      RUBY

      #
      # Add method call to instance: user.enable_something
      #
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{action}(params={})
          self.class.#{method}("\#{request_path}/#{action.to_s.delete('!')}", params)
        end
      RUBY
    end
  end
end
