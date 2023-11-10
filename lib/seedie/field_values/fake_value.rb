# frozen_string_literal: true

module Seedie
  module FieldValues
    class FakeValue
      def initialize(name, column)
        @name = name
        @column = column
      end

      def generate_fake_value
        case @column.type
        when :string, :text, :citext
          generate_string
        when :uuid
          generate_uuid
        when :integer, :bigint, :smallint
          generate_integer
        when :decimal, :float, :real
          generate_decimal
        when :datetime, :timestamp, :timestamptz
          generate_datetime
        when :date
          generate_date
        when :time, :timetz
          generate_time
        when :boolean
          generate_boolean
        when :json, :jsonb
          generate_json
        when :inet
          generate_inet
        when :cidr, :macaddr
          generate_macaddr
        when :bytea
          generate_bytea
        when :bit, :bit_varying
          generate_bit
        when :money
          generate_money
        when :hstore
          generate_hstore
        when :year
          generate_year
        else
          raise UnknownColumnTypeError, "Unknown column type: #{@column.type}"
        end
      end

      private

      def generate_string
        Faker::Lorem.word
      end

      def generate_uuid
        SecureRandom.uuid
      end

      def generate_integer
        Faker::Number.number(digits: 5)
      end

      def generate_decimal
        Faker::Number.decimal(l_digits: 2, r_digits: 2)
      end

      def generate_datetime
        Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
      end

      def generate_date
        Faker::Date.between(from: Date.today - 2, to: Date.today)
      end

      def generate_time
        Faker::Time.forward(days: 23, period: :morning)
      end

      def generate_boolean
        Faker::Boolean.boolean
      end

      def generate_json
        { "value" => { "key1" => Faker::Lorem.word, "key2" => Faker::Number.number(digits: 2) } }
      end

      def generate_inet
        Faker::Internet.ip_v4_address
      end

      def generate_macaddr
        Faker::Internet.mac_address
      end

      def generate_bytea
        Faker::Internet.password
      end

      def generate_bit
        %w[0 1].sample
      end

      def generate_money
        Faker::Commerce.price.to_s
      end

      def generate_hstore
        { "value" => { "key1" => Faker::Lorem.word, "key2" => Faker::Number.number(digits: 2) } }
      end

      def generate_year
        rand(1901..2155)
      end
    end
  end
end
