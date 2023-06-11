module Seedie
  class ModelLoader
    DEFAULT_MODEL_COUNT = 1

    attr_reader :model, :model_config, :model_name, :config

    def initialize(model_name, model_config, config)
      @model_name = model_name
      @model = model_name.capitalize.constantize
      @model_config = model_config
      @config = config
    end

    def generate_records
      model_count(model_config).times do |index|
        generate_record(model_config, index)
      end
    end

    private

    def model_count(model_config)
      return model_config['count'] if model_config['count'].present?
      return config['default_count'] if config['default_count'].present?

      DEFAULT_MODEL_COUNT
    end

    def generate_record(model_config, index)
      field_values_set = FieldValuesSet.new(model, model_config, index).generate_field_values
      model.create!(field_values_set)
    end
  end
end