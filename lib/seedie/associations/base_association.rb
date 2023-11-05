module Seedie
  module Associations
    class BaseAssociation
      include Reporters::Reportable

      DEFAULT_COUNT = 1
      INDEX = 0

      attr_reader :record, :model, :association_config, :reporters

      def initialize(record, model, association_config, reporters = [])
        @record = record
        @model = model
        @association_config = association_config
        @reporters = reporters

        add_observers(@reporters)
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

      def generate_associated_field(id, association_name)
        { "#{association_name}" => id }
      end
    end
  end
end
