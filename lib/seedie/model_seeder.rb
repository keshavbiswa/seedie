# frozen_string_literal: true

module Seedie
  class ModelSeeder
    include Reporters::Reportable

    DEFAULT_MODEL_COUNT = 1

    attr_reader :model, :model_config, :config, :reporters

    def initialize(model, model_config, config, reporters)
      @model = model
      @model_config = model_config
      @config = config
      @record_creator = Model::Creator.new(model, reporters)
      @reporters = reporters
      add_observers(@reporters)
    end

    def generate_records
      report(:model_seed_start, name: model.to_s)
      model_count(model_config).times do |index|
        record = generate_record(model_config, index)
        associations_config = model_config["associations"]

        if associations_config.present?
          Associations::HasMany.new(record, model, associations_config, reporters).generate_associations
          Associations::HasOne.new(record, model, associations_config, reporters).generate_associations
        end
      end
      report(:model_seed_finish, name: model.to_s)
    end

    private

    def model_count(model_config)
      return model_config["count"] if model_config["count"].present?
      return config["default_count"] if config["default_count"].present?

      DEFAULT_MODEL_COUNT
    end

    def generate_record(model_config, index)
      field_values_set = FieldValuesSet.new(model, model_config, index).generate_field_values_with_associations
      @record_creator.create!(field_values_set)
    end
  end
end
