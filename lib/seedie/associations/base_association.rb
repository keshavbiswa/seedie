module Seedie
  class BaseAssociation
    DEFAULT_COUNT = 1

    attr_reader :record, :model, :model_config

    def initialize(record, model, model_config)
      @record = record
      @model = model
      @model_config = model_config
    end

    def generate_associations
      raise NotImplementedError
    end

    def generate_association
      raise NotImplementedError
    end

    private

    def get_association_count(association_config)
      return association_config if only_count_given?(association_config)
      return association_config["count"] if association_config["count"].present?

      DEFAULT_COUNT
    end

    def only_count_given?(association_config)
      association_config.is_a?(Numeric) || association_config.is_a?(String)
    end
  end
end