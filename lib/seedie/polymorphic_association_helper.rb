module Seedie
  module PolymorphicAssociationHelper
    # Returns the type of the polymorphic association
    # We need only one polymorphic association while generating config
    # this makes it easier to sort according to dependencies
    def find_polymorphic_types(model, association_name)
      type = @models.find { |potential_model| has_association?(potential_model, association_name) }
      type&.name&.underscore
    end

    def has_association?(model, association_name)
      associations = select_associations(model)
      associations.any? { |association| association.options[:as] == association_name }
    end
    
    def select_associations(model)
      model.reflect_on_all_associations.select do |reflection|
        %i[has_many has_one].include?(reflection.macro)
      end
    end
  end
end