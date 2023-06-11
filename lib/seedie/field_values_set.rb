module Seedie
  class FieldValuesSet
    attr_reader :attributes_config, :index

    def initialize(model, model_config, index)
      @model = model
      @model_config = model_config
      @index = index
      @attributes_config = model_config['attributes']
      @model_fields = ModelFields.new(model, model_config)
      @field_values = {}
    end

    def generate_field_values
      @field_values = @model.columns_hash.map do |name, column|
        next if @model_fields.disabled_fields.include?(name)
        next if @model_fields.foreign_fields.include?(name)
        
        [name, generate_field_value(name, column)]
      end

      @field_values.compact.to_h
    end

    def generate_field_value(name, column)
      custom_value = attributes_config && attributes_config[name]

      if custom_value.present?
        FieldValues::CustomValue.new(name, custom_value, index).generate_custom_field_value
      else
        FieldValues::FakeValue.new(name, column).generate_fake_value
      end
    end
  end
end