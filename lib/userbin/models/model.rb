require 'her'

module Userbin
  class Model
    include Her::Model
    use_api Userbin::API

    def initialize(args = {})
      # allow initializing with id as a string
      args = { id: args } if args.is_a? String
      super(args)
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
      # Add method calls to association: user.challenges.verify(id, attributes)
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
      # Add method call to instance: user.enable_mfa
      #
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{action}(params={})
          self.class.#{method}("\#{request_path}/#{action}", params)
        end
      RUBY
    end
  end
end
