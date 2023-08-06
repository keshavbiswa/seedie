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
          reflection = model.reflect_on_association(association_name)

          handle_association_config_type(reflection, association_name, association_config)
        end
      end

      def generate_association(klass, config, index)
        field_values_set = FieldValuesSet.new(klass, config, index).generate_field_values

        Model::Creator.new(klass).create!(field_values_set)
      end

      private

      def handle_association_config_type(reflection, association_name, association_config)
        if reflection.polymorphic?
          handle_polymorphic_config_type(reflection, association_config)
        else
          klass = reflection.klass
          strategy = get_type(association_config)
          handle_strategy(klass, reflection, strategy)
        end
      end
      

      def handle_polymorphic_config_type(reflection, association_config)
        type_name = get_polymorphic_class_name(association_config["polymorphic"])
        klass = type_name.classify.constantize
        strategy = get_type(association_config["strategy"])
        associated_field_set.merge!(generate_associated_field(klass.to_s, reflection.foreign_type))

        handle_strategy(klass, reflection, strategy)
      end
      
      # Handles the strategy for belongs_to associations
      # For polymorphic reflection, we might not add a strategy
      # so we need to default it to random
      def handle_strategy(klass, reflection, strategy)
        strategy ||= reflection.polymorphic? ? "random" : nil

        case get_type(strategy)
        when "random"
          handle_random_config_type(klass, reflection)
        when "unique"
          handle_unique_config_type(klass, reflection)
        when "new"
          handle_new_config_type(klass, reflection)
        else
          handle_other_config_type(klass, reflection, strategy)
        end
      end

      # polymorphic option can either be single value "post" or an array ["post", "game_room"]
      # type pick strategy will be either the single value or a random value from the array
      def get_polymorphic_class_name(polymorphic_types)
        polymorphic_types.is_a?(String) ? polymorphic_types : polymorphic_types.sample
      end

      def handle_random_config_type(klass, reflection)
        id = Model::IdGenerator.new(klass).random_id

        report(:random_association, name: klass.to_s, parent_name: model.to_s, id: id)
        associated_field_set.merge!(generate_associated_field(id, reflection.foreign_key))
      end

      def handle_unique_config_type(klass, reflection)
        report(:unique_association, name: klass.to_s, parent_name: @model.to_s)

        id = Model::IdGenerator.new(klass).unique_id_for(@model, reflection.foreign_key)
        associated_field_set.merge!(generate_associated_field(id, reflection.foreign_key))
      end

      def handle_new_config_type(klass, reflection)
        report(:belongs_to_associations, name: klass.to_s, parent_name: model.to_s)
            
        new_associated_record = generate_association(klass, {}, INDEX)
        associated_field_set.merge!(generate_associated_field(new_associated_record.id, reflection.foreign_key))
      end

      def handle_other_config_type(klass, reflection, association_config)
        report(:belongs_to_associations, name: klass.to_s, parent_name: model.to_s)
            
        new_associated_record = generate_association(klass, association_config, INDEX)
        associated_field_set.merge!(generate_associated_field(new_associated_record.id, reflection.foreign_key))
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