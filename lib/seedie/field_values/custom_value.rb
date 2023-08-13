module Seedie
  module FieldValues
    class CustomValue
      VALID_KEYS = ["values", "value", "options"].freeze
      PICK_STRATEGIES = ["random", "sequential"].freeze
      
      attr_reader :name, :parsed_value

      def initialize(name, value_template, index)
        @name = name
        @value_template = value_template
        @index = index
        @parsed_value = ""

        validate_value_template
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

      def validate_value_template
        return if @value_template.is_a?(String)

        validate_keys
        validate_values if @value_template.key?("values")
        validate_options if @value_template.key?("options")
      end

      def validate_values
        values = @value_template["values"]
        options = @value_template["options"]
        
        if values.is_a?(Array)
          if options.present? && options["pick_strategy"] == "sequential"
            validate_values_length
          end
        else
          raise InvalidCustomFieldValuesError, "The values key for #{@name} must be an array."
        end
      end

      def validate_options
        options = @value_template["options"]
        pick_strategy = options["pick_strategy"]

        if pick_strategy.present? && !PICK_STRATEGIES.include?(pick_strategy)
          raise InvalidCustomFieldOptionsError,
            "The pick_strategy for name must be either 'sequential' or 'random'."
        end
      end

      def validate_values_length
        values = @value_template["values"]
        values_length = values.length

        if values_length < @index + 1
          raise CustomFieldNotEnoughValuesError,
            "There are not enough values for #{@name}. Please add more values."
        end
      end

      def validate_keys
        invalid_keys = @value_template.keys - VALID_KEYS
  
        if invalid_keys.present?
          raise InvalidCustomFieldKeysError,
            "Invalid keys for #{@name}: #{invalid_keys.join(", ")}. Only #{VALID_KEYS} are allowed."
        end

        if @value_template.key?("values") && @value_template.key?("value")
          raise InvalidCustomFieldKeysError,
            "Invalid keys for #{@name}: values and value cannot be used together."
        end
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
        if @value_template.key?("values")
          values = @value_template["values"]
          options = @value_template["options"]
          
          if options.present? && options["pick_strategy"] == "sequential"
            @parsed_value = values[@index]
          else
            @parsed_value = values.sample
          end
        elsif @value_template.key?("value")
          @parsed_value = @value_template["value"]
        end
      end
    end
  end
end
