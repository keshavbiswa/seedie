module Seedie
  module FieldValues
    class CustomValue
      attr_reader :name, :parsed_value

      def initialize(name, value_template, index)
        @name = name
        @value_template = value_template
        @index = index
        @parsed_value = ""
      end

      def generate_custom_field_value
        parsed_value = @value_template.gsub("{{index}}", @index.to_s)

        parsed_value.gsub!(/\{\{(.+?)\}\}/) do
          method_string = $1

          if method_string.start_with?("Faker::")
            eval($1)
          else
            raise InvalidFakerMethodError, "Invalid method: #{method_string}"
          end
        end

        parsed_value
      end
    end
  end
end
