module Seedie
  module Associations
    class BelongsTo < BaseAssociation
      attr_reader :associated_field_set

      def initialize(model, association_config, reporters = [])
        super(nil, model, association_config, reporters)

        @associated_field_set = {}
      end

      def generate_associations
        return if association_config["belongs_to"].nil?
        
        report(:belongs_to_start)
        association_config["belongs_to"].each do |association_name, association_config|
          klass = association_name.to_s.classify.constantize
          association_config_type = get_type(association_config)
          
          if association_config_type == "random"
            id = RecordCreator.new(klass).get_random_id

            report(:random_association, name: klass.to_s, parent_name: model.to_s, id: id)
            associated_field_set.merge!(generate_associated_field(id, association_name))
          elsif association_config_type == "new"
            report(:belongs_to_associations, name: klass.to_s, parent_name: model.to_s)
            
            new_associated_record = generate_association(klass, {}, INDEX)
            associated_field_set.merge!(generate_associated_field(new_associated_record.id, association_name))
          else
            report(:belongs_to_associations, name: klass.to_s, parent_name: model.to_s)
            
            new_associated_record = generate_association(klass, association_config, INDEX)
            associated_field_set.merge!(generate_associated_field(new_associated_record.id, association_name))
          end
        end
      end

      def generate_association(klass, config, index)
        field_values_set = FieldValuesSet.new(klass, config, index).generate_field_values

        RecordCreator.new(klass).create!(field_values_set)
      end

      private

      def get_type(association_config)
        if association_config.is_a?(String)
          raise InvalidAssociationConfigError, "Invalid association config" unless ["random", "new"].include?(association_config)

          return association_config
        else
          association_config
        end
      end
    end
  end
end