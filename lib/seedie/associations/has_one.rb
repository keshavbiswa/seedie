module Seedie
  module Associations
    class HasOne < BaseAssociation
      def generate_associations
        return if association_config["has_one"].nil?

        report(:has_one_start)
        
        association_config["has_one"].each do |association_name, association_config|
          reflection = model.reflect_on_association(association_name)
          association_class = reflection.klass
          count = get_association_count(association_config)
          
          report(:associated_records, count: count, name: association_name, parent_name: model.to_s)
          if count > 1
            raise InvalidAssociationConfigError, "has_one association cannot be more than 1"
          else
            config = only_count_given?(association_config) ? {} : association_config
            field_values_set = FieldValuesSet.new(association_class, config, INDEX).generate_field_values
            parent_field_set = generate_associated_field(record.id, reflection.foreign_key)
            
            record_creator = Model::Creator.new(association_class, reporters)
            record_creator.create!(field_values_set.merge!(parent_field_set))
          end
        end
      end
    end
  end
end