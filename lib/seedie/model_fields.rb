module Seedie
  class ModelFields
    DEFAULT_DISABLED_FIELDS = %w[id created_at updated_at]

    attr_reader :model_name, :model_config, :fields, :disabled_fields
    
    def initialize(model, model_config)
      @model_name = model.to_s
      @model_config = model_config
      @custom_fields = model_config['attributes']&.keys || []
      @disabled_fields = [model_config['disabled_fields'] + DEFAULT_DISABLED_FIELDS].flatten.uniq
      @other_fields = model.column_names - @disabled_fields - @custom_fields
    end
  end
end