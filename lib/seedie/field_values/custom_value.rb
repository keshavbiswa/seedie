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
            method_chain = method_string.split('.')
            # Faker::Name will be shifted off the array
            faker_class = method_chain.shift.constantize

            # For Faker::Internet.unique.email, there will be two methods in the array
            method_chain.reduce(faker_class) do |current_class_or_value, method|
              current_class_or_value.public_send(method)
            end
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
