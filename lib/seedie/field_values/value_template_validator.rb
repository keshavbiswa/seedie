# frozen_string_literal: true

module Seedie
  module FieldValues
    class ValueTemplateValidator
      VALID_KEYS = %w[values value options].freeze
      PICK_STRATEGIES = %w[random sequential].freeze

      def initialize(value_template, index, name)
        @value_template = value_template
        @index = index
        @name = name
      end

      def validate
        return unless @value_template.is_a?(Hash)

        validate_keys
        validate_values if @value_template.key?("values")
        validate_options if @value_template.key?("options")
      end

      private

      def validate_keys
        invalid_keys = @value_template.keys - VALID_KEYS

        if invalid_keys.present?
          raise InvalidCustomFieldKeysError,
                "Invalid keys for #{@name}: #{invalid_keys.join(', ')}. Only #{VALID_KEYS} are allowed."
        end

        return unless @value_template.key?("values")

        if @value_template.key?("value")
          raise InvalidCustomFieldKeysError,
                "Invalid keys for #{@name}: values and value cannot be used together."
        end

        return unless @value_template["values"].is_a?(Hash)

        return unless !@value_template["values"].key?("start") || !@value_template["values"].key?("end")

        raise InvalidCustomFieldValuesError,
              "The values key for #{@name} must be an array or a hash with start and end keys."
      end

      def validate_values
        values = @value_template["values"]

        unless values.is_a?(Array) || values.is_a?(Hash)
          raise InvalidCustomFieldValuesError,
                "The values key for #{@name} must be an array or a hash with start and end keys."
        end

        validate_sequential_values_length
      end

      def validate_options
        options = @value_template["options"]
        pick_strategy = options["pick_strategy"]

        return unless pick_strategy.present? && !PICK_STRATEGIES.include?(pick_strategy)

        raise InvalidCustomFieldOptionsError,
              "The pick_strategy for #{@name} must be either 'sequential' or 'random'."
      end

      ## If pick strategy is sequential, we need to ensure there is a value for each index
      # If there isn't sufficient values, we raise an error
      def validate_sequential_values_length
        return unless @value_template.key?("options")
        return unless @value_template["options"]["pick_strategy"] == "sequential"

        values = @value_template["values"]

        values_length = if values.is_a?(Hash) && values.keys.sort == %w[end start]
                          # Assuming the values are an inclusive range
                          values["end"] - values["start"] + 1
                        else
                          values.length
                        end

        return unless values_length < @index + 1

        raise CustomFieldNotEnoughValuesError,
              "There are not enough values for #{@name}. Please add more values."
      end
    end
  end
end
