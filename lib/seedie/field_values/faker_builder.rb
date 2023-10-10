# frozen_string_literal: true

module Seedie
  module FieldValues
    class FakerBuilder
      def initialize(name, column, validations)
        @name = name
        @column = column
        @validations = validations
        @faker_expression = "{{Faker::"
        @unique_prefix = ""
        @class_prefix = ""
        @method_prefix = ""
        @options = ""
        @seedie_config_custom_attributes = Seedie.configuration.custom_attributes
      end

      def build_faker_constant
        return @seedie_config_custom_attributes[@name.to_sym] if @seedie_config_custom_attributes.key?(@name.to_sym)

        @unique_prefix = "unique." if has_validation?(:uniqueness)

        add_faker_class_and_method(@column.type)

        if has_validation?(:inclusion)
          handle_inclusion_validation
        else
          @options += handle_numericality_validation if has_validation?(:numericality)
          @options += handle_length_validation if has_validation?(:length)
        end

        if @faker_expression.is_a?(String)
          @faker_expression += "#{@class_prefix}#{@unique_prefix}#{@method_prefix}#{@options}"
          @faker_expression += "}}" if @faker_expression.start_with?("{{") # We may not need }} when random attributes
        end

        @faker_expression
      end

      private

        def add_faker_class_and_method(type)
          case type
          when :string, :text, :citext
            @class_prefix = "Lorem."
            @method_prefix = "word"
          when :uuid
            @class_prefix = "Internet."
            @method_prefix = "uuid"
          when :integer, :bigint, :smallint
            @class_prefix = "Number."
            @method_prefix = "number"
            @options = "(digits: 5)"
          when :decimal, :float, :real
            @class_prefix = "Number."
            @method_prefix = "decimal"
            @options = "(l_digits: 2, r_digits: 2)"
          when :datetime, :timestamp, :timestamptz, :time, :timetz
            @class_prefix = "Time."
            @method_prefix = "between"
            @options = "(from: DateTime.now - 1, to: DateTime.now)"
          when :date
            @class_prefix = "Date."
            @method_prefix = "between"
            @options = "(from: Date.today - 1, to: Date.today)"
          when :boolean
            @class_prefix = "Boolean."
            @method_prefix = "boolean"
          when :json, :jsonb
            @faker_expression = {
              "value" => "Json.shallow_json(width: 3,
              options: { key: 'Name.first_name', value: 'Number.number(digits: 2)' })"
            }
          when :inet
            @class_prefix = "Internet."
            @method_prefix = "ip_v4_address"
          when :cidr, :macaddr
            @class_prefix = "Internet."
            @method_prefix = "mac_address"
          when :bytea
            @class_prefix = "Internet."
            @method_prefix = "password"
          when :bit, :bit_varying
            @class_prefix = "Internet."
            @method_prefix = "password"
          when :money
            @class_prefix = "Commerce."
            @method_prefix = "price.to_s"
          when :hstore
            @faker_expression = {
              "value" => "Json.shallow_json(width: 3,
              options: { key: 'Name.first_name', value: 'Number.number(digits: 2)' })"
            }
          when :year
            @class_prefix = "Number."
            @method_prefix = "number"
            @options = "(digits: 4)"
          else
            raise UnknownColumnTypeError, "Unknown column type: #{type}"
          end
        end

        def has_validation?(kind)
          @validations.any? { |validation| validation.kind == kind }
        end

        def handle_numericality_validation
          numericality_validator = @validations.find { |v| v.kind == :numericality }
          options = numericality_validator.options
          if options[:greater_than_or_equal_to] && options[:less_than_or_equal_to]
            ".between(from: #{options[:greater_than_or_equal_to]}, to: #{options[:less_than_or_equal_to]})"
          elsif options[:greater_than_or_equal_to]
            ".between(from: #{options[:greater_than_or_equal_to]})"
          elsif options[:less_than_or_equal_to]
            ".between(to: #{options[:less_than_or_equal_to]})"
          else
            ""
          end
        end

        def handle_length_validation
          length_validator = @validations.find { |v| v.kind == :length }
          @method_prefix = "characters"
          options = length_validator.options
          if options[:minimum] && options[:maximum]
            "(number: rand(#{options[:minimum]}..#{options[:maximum]}))"
          elsif options[:minimum]
            "(number: rand(#{options[:minimum]}..100))"
          elsif options[:maximum]
            "(number: rand(1..#{options[:maximum]}))"
          else
            ""
          end
        end

        def handle_inclusion_validation
          inclusion_validator = @validations.find { |v| v.kind == :inclusion }
          options = inclusion_validator.options
          @class_prefix = ""
          @method_prefix = ""
          @options = ""
          if options[:in].is_a?(Range)
            @faker_expression = {
              "values" => { "start" => options[:in].first, "end" => options[:in].last },
              "options" => { "pick_strategy" => "random" }
            }
          else
            @faker_expression = { "values" => options[:in], "options" => { "pick_strategy" => "random" } }
          end
        end
    end
  end
end
