module Seedie
  module Associations
    class BelongsTo < BaseAssociation
      attr_reader :model, :association_config, :associated_field_set

      def initialize(model, association_config)
        @model = model
        @association_config = association_config
        @associated_field_set = {}
      end

      def generate_associations
        return if association_config["belongs_to"].nil?
        
        association_config["belongs_to"].each do |association_name, association_config|
          klass = association_name.to_s.classify.constantize
          count = get_association_count(association_config)
          
          if count > 1
            raise InvalidAssociationConfigError, "belongs_to association cannot be more than 1"
          else
            config = only_count_given?(association_config) ? {} : association_config
            field_values_set = FieldValuesSet.new(klass, config, INDEX).generate_field_values
            
            klass.create!(field_values_set)
            associated_field_set["#{association_name}_id"] = klass.last.id
          end
        end
      end
    end
  end
end