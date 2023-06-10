module Seedie
  module FieldValues
    class CustomValue
      def initialize(name, value_template, index)
        @name = name
        @value_template = value_template
        @index = index
      end

      def generate_custom_field_value
        @value_template.gsub("{{index}}", @index.to_s)
      end
    end
  end
end
