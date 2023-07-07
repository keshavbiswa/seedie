module Seedie
  class ModelSeeder
    include Reporters::Reportable

    DEFAULT_MODEL_COUNT = 1

    attr_reader :model, :model_config, :config

    def initialize(model, model_config, config, reporters)
      @model = model
      @model_config = model_config
      @config = config
      @record_creator = RecordCreator.new(model)
      @reporters = reporters
      add_observers(@reporters)
    end

    def generate_records
      notify(:model_seed_start, name: "#{model.to_s}")
      model_count(model_config).times do |index|
        record = generate_record(model_config, index)
        associations_config = model_config["associations"]

        if associations_config.present?
          Associations::HasMany.new(record, model, associations_config).generate_associations
          Associations::HasOne.new(record, model, associations_config).generate_associations
        end
      end
    end

    private

    def model_count(model_config)
      return model_config["count"] if model_config["count"].present?
      return config["default_count"] if config["default_count"].present?

      DEFAULT_MODEL_COUNT
    end

    def generate_record(model_config, index)
      associated_field_set = generate_belongs_to_associations(model, model_config)

      field_values_set = FieldValuesSet.new(model, model_config, index).generate_field_values
      field_values_set.merge!(associated_field_set)
      @record_creator.create!(field_values_set)
    end

    def generate_belongs_to_associations(model, model_config)
      associations_config = model_config["associations"]
      return {} unless associations_config.present?

      belongs_to_associations = Associations::BelongsTo.new(model, associations_config)
      belongs_to_associations.generate_associations
      
      return belongs_to_associations.associated_field_set
    end
  end
end