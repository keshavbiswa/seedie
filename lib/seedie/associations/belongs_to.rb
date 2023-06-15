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
          association_config_type = get_type(association_config)
          
          if association_config_type == "random"
            id = RecordCreator.new(klass).get_random_id

            set_associated_field_set(id, association_name)
          elsif association_config_type == "new"
            record = generate_association(klass, {}, INDEX)
            set_associated_field_set(record.id, association_name)
          else
            record = generate_association(klass, association_config, INDEX)
            set_associated_field_set(record.id, association_name)
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

      def set_associated_field_set(id, association_name)
        associated_field_set["#{association_name}_id"] = id
      end
    end
  end
end