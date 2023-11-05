module Seedie
  class ModelFields
    DEFAULT_DISABLED_FIELDS = %w[id created_at updated_at]

    attr_reader :model_name, :model_config, :fields, :disabled_fields, :foreign_fields

    def initialize(model, model_config)
      @model_name = model.to_s
      @model_config = model_config
      @custom_fields = model_config["attributes"]&.keys || []
      @disabled_fields = [(model_config["disabled_fields"] || []) + DEFAULT_DISABLED_FIELDS].flatten.uniq
      @foreign_fields = model.reflect_on_all_associations(:belongs_to).map(&:foreign_key)
      @other_fields = model.column_names - @disabled_fields - @custom_fields - @foreign_fields
    end
  end
end
