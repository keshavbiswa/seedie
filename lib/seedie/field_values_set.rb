module Seedie
  class FieldValuesSet
    attr_reader :model, :model_config, :attributes_config, :index

    def initialize(model, model_config, index)
      @model = model
      @model_config = model_config
      @index = index
      @attributes_config = model_config["attributes"]
      @model_fields = ModelFields.new(model, model_config)
      @field_values = {}
    end

    def generate_field_values
      populate_values_for_model_fields
      populate_values_for_virtual_fields if @attributes_config

      @field_values
    end

    def generate_field_values_with_associations
      associated_field_values_set = generate_belongs_to_associations
      model_field_values_set = generate_field_values
      model_field_values_set.merge!(associated_field_values_set)
    end

    def generate_field_value(name, column)
      return generate_custom_field_value(name) if @attributes_config&.key?(name)

      FieldValues::FakeValue.new(name, column).generate_fake_value
    end

    private

    def generate_belongs_to_associations
      associations_config = model_config["associations"]
      return {} unless associations_config.present?

      belongs_to_associations = Associations::BelongsTo.new(model, associations_config)
      belongs_to_associations.generate_associations
      belongs_to_associations.associated_field_set
    end

    def populate_values_for_model_fields
      @field_values = @model.columns_hash.map do |name, column|
        next if @model_fields.disabled_fields.include?(name)
        next if @model_fields.foreign_fields.include?(name)

        [name, generate_field_value(name, column)]
      end.compact.to_h
    end

    def populate_values_for_virtual_fields
      virtual_fields = @attributes_config.keys - @model.columns_hash.keys

      virtual_fields.each do |name|
        @field_values[name] = generate_custom_field_value(name) if @attributes_config[name]
      end
    end

    def generate_custom_field_value(name)
      FieldValues::CustomValue.new(name, @attributes_config[name], @index).generate_custom_field_value
    end
  end
end
