#
# Add destroy to association: user.events.destroy(id)
#
module Her::Model::Associations
  class AssociationProxy
    install_proxy_methods :association, :destroy
  end

  class HasManyAssociation < Association ## remove inheritance
    def destroy(id)
      @klass.destroy_existing(id, :"#{@parent.singularized_resource_name}_id" => @parent.id)
    end
  end
end
