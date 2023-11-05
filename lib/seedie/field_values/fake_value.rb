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
          Faker::Lorem.word
        when :uuid
          SecureRandom.uuid
        when :integer, :bigint, :smallint
          Faker::Number.number(digits: 5)
        when :decimal, :float, :real
          Faker::Number.decimal(l_digits: 2, r_digits: 2)
        when :datetime, :timestamp, :timestamptz
          Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
        when :date
          Faker::Date.between(from: Date.today - 2, to: Date.today)
        when :time, :timetz
          Faker::Time.forward(days: 23, period: :morning)
        when :boolean
          Faker::Boolean.boolean
        when :json, :jsonb
          { "value" => { "key1" => Faker::Lorem.word, "key2" => Faker::Number.number(digits: 2) } }
        when :inet
          Faker::Internet.ip_v4_address
        when :cidr, :macaddr
          Faker::Internet.mac_address
        when :bytea
          Faker::Internet.password
        when :bit, :bit_varying
          ["0", "1"].sample
        when :money
          Faker::Commerce.price.to_s
        when :hstore
          { "value" => { "key1" => Faker::Lorem.word, "key2" => Faker::Number.number(digits: 2) } }
        when :year
          rand(1901..2155)
        else
          raise UnknownColumnTypeError, "Unknown column type: #{@column.type}"
        end
      end
    end
  end
end
