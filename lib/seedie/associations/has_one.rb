module Seedie
  module Associations
    class HasOne < BaseAssociation
      def generate_associations
        return if association_config["has_one"].nil?
        
        association_config["has_one"].each do |association_name, association_config|
          association_class = association_name.to_s.classify.constantize
          count = get_association_count(association_config)
          
          if count > 1
            raise InvalidAssociationConfigError, "has_one association cannot be more than 1"
          else
            config = only_count_given?(association_config) ? {} : association_config
            field_values_set = FieldValuesSet.new(association_class, config, INDEX).generate_field_values
            record.send("build_#{association_name}", field_values_set)
            record.save!
          end
        end
      end
    end
  end
end