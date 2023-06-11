module Seedie
  class AssociationsLoader
    attr_reader :record, :model, :model_config

    def initialize(record, model, model_config)
      @record = record
      @model = model
      @model_config = model_config
    end

    def generate_associations
      model_config["associations"].each do |association_name, association_config|
        association_class = association_name.to_s.classify.constantize
        count = get_association_count(association_config)
        config = only_count_given?(association_config) ? {} : association_config

        count.times do |index|
          field_values_set = FieldValuesSet.new(association_class, config, index).generate_field_values
          record.send(association_name).create!(field_values_set)
        end
      end
    end

    private

      def get_association_count(association_config)
        return association_config if only_count_given?(association_config)
        return association_config["count"] if association_config["count"].present?

        1
      end

      def only_count_given?(association_config)
        association_config.is_a?(Numeric)
      end
  end
end