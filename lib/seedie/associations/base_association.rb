module Seedie
  class BaseAssociation
    DEFAULT_COUNT = 1

    attr_reader :record, :model, :association_config

    def initialize(record, model, association_config)
      @record = record
      @model = model
      @association_config = association_config
    end

    def generate_associations
      raise NotImplementedError
    end

    def generate_association
      raise NotImplementedError
    end

    private

    def get_association_count(config)
      return config if only_count_given?(config)
      return config["count"] if config["count"].present?

      DEFAULT_COUNT
    end

    def only_count_given?(config)
      config.is_a?(Numeric) || config.is_a?(String)
    end
  end
end