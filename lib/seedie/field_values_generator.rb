module Seedie
  class FieldValuesGenerator
    attr_reader :attributes_config, :index

    def initialize(model, model_config, index)
      @model = model
      @model_config = model_config
      @index = index
      @model_fields = ModelFields.new(model, model_config)
      @field_values = {}
    end

    def generate_field_values
      @model.column_hash.map do |name, column|
        next if @model_fields.disabled_fields.include?(name)
        
        [name, generate_field_value(name, column)]
      end.to_h
    end

    def generate_field_value(name, column)
      if attributes_config[name].present?
        CustomFieldValueGenerator.new(name, attributes_config[name], index).generate_custom_field_value
      else
        FakeValueGenerator.new(name, column).generate_fake_value
      end
    end
  end
end