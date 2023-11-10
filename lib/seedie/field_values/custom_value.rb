module Seedie
  module FieldValues
    class CustomValue
      attr_reader :name, :parsed_value

      def initialize(name, value_template, index)
        @name = name
        @value_template = value_template
        @index = index
        @parsed_value = ""

        ValueTemplateValidator.new(@value_template, @index, @name).validate
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
          values =  if @value_template["values"].is_a?(Array)
                      @value_template["values"]
                    else
                      # generate_custom_value_from_range
                      generate_custom_values_from_range(@value_template["values"]["start"], @value_template["values"]["end"])
                    end
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

      def generate_custom_values_from_range(start, ending)
        (start..ending).to_a
      end
    end
  end
end
