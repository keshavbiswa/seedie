module Seedie
  module FieldValues
    class CustomValue
      VALID_KEYS = ["values", "pick"]
      CUSTOM_VALUE = "custom_attr_value"

      attr_reader :name, :parsed_value

      def initialize(name, value_template, index)
        @name = name
        @value_template = value_template
        @index = index
        @parsed_value = ""
        @custom_attr_value = false
        
        validate_template if @value_template.is_a?(Hash) && @value_template.has_key?(CUSTOM_VALUE)
      end

      def generate_custom_field_value
        if @value_template.is_a?(String)
          generate_custom_value_from_string
        else
          generate_custom_value_from_hash
        end

        parsed_value
      end

      private

      def validate_template
        @value_template = @value_template[CUSTOM_VALUE]
        @custom_attr_value = true

        validate_hash_keys
        validate_values_key
        validate_pick_key
      end

      def validate_hash_keys
        invalid_keys = @value_template.keys - VALID_KEYS
        return if invalid_keys.empty?

        raise InvalidCustomFieldKeysError, 
          "Invalid keys for #{@name}: #{invalid_keys.join(", ")}. Only 'values' and 'pick' are allowed."
      end

      def validate_values_key
        return if @value_template["values"].is_a?(Array)

        raise InvalidCustomFieldValuesError, "The values key for #{@name} must be an array."
      end

      def validate_values_length
        return if @value_template["values"].length >= @index

        raise CustomFieldNotEnoughValuesError, "There are not enough values for name. Please add more values."
      end

      def validate_pick_key
        @pick = @value_template["pick"] || "random"
        return if %w[random sequential].include?(@pick)

        raise CustomFieldInvalidPickValueError, "The pick value for #{@name} must be either 'sequential' or 'random'."
      end

      def generate_custom_value_from_string
        @parsed_value = @value_template.gsub("{{index}}", @index.to_s)

        @parsed_value.gsub!(/\{\{(.+?)\}\}/) do
          method_string = $1

          if method_string.start_with?("Faker::")
            eval($1)
          else
            raise InvalidFakerMethodError, "Invalid method: #{method_string}"
          end
        end
      end

      def generate_custom_value_from_hash
        if @custom_attr_value
          values = @value_template["values"]
          if @pick == "sequential"
            validate_values_length

            @parsed_value = values[@index]
          else
            @parsed_value = values.sample
          end
        else
          @parsed_value = @value_template
        end
      end
    end
  end
end
