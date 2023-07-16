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
          record_creator = Model::Creator.new(klass, reporters)

          handle_association_config_type(klass, association_name, association_config, record_creator)
        end
      end

      def generate_association(klass, config, index)
        field_values_set = FieldValuesSet.new(klass, config, index).generate_field_values

        Model::Creator.new(klass).create!(field_values_set)
      end

      private

      def handle_association_config_type(klass, association_name, association_config, record_creator)
        case get_type(association_config)
        when "random"
          handle_random_config_type(klass, association_name, record_creator)
        when "unique"
          handle_unique_config_type(klass, association_name, record_creator)
        when "new"
          handle_new_config_type(klass, association_name, record_creator)
        else
          handle_other_config_type(klass, association_name, association_config, record_creator)
        end
      end

      def handle_random_config_type(klass, association_name, record_creator)
        id = record_creator.get_random_id

        report(:random_association, name: klass.to_s, parent_name: model.to_s, id: id)
        associated_field_set.merge!(generate_associated_field(id, association_name))
      end

      def handle_unique_config_type(klass, association_name, record_creator)
        report(:unique_association, name: klass.to_s, parent_name: model.to_s)

        id = record_creator.get_unique_id(model)
        associated_field_set.merge!(generate_associated_field(id, association_name))
      end

      def handle_new_config_type(klass, association_name, record_creator)
        report(:belongs_to_associations, name: klass.to_s, parent_name: model.to_s)
            
        new_associated_record = generate_association(klass, {}, INDEX)
        associated_field_set.merge!(generate_associated_field(new_associated_record.id, association_name))
      end

      def handle_other_config_type(klass, association_name, association_config, record_creator)
        report(:belongs_to_associations, name: klass.to_s, parent_name: model.to_s)
            
        new_associated_record = generate_association(klass, association_config, INDEX)
        associated_field_set.merge!(generate_associated_field(new_associated_record.id, association_name))
      end

      def get_type(association_config)
        if association_config.is_a?(String)
          raise InvalidAssociationConfigError, "Invalid association config" unless ["random", "new", "unique"].include?(association_config)

          return association_config
        else
          association_config
        end
      end
    end
  end
end