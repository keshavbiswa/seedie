module Seedie
  module FieldValues
    class FakeValue
      def initialize(name, column)
        @name = name
        @column = column
      end

      def generate_fake_value
        case @column.type
        when :string
          Faker::Lorem.word
        when :text
          Faker::Lorem.paragraph
        when :integer
          Faker::Number.number(digits: 2)
        when :datetime
          Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
        when :boolean
          Faker::Boolean.boolean
        else
          raise "Unknown column type: #{@column.type}"
        end
      end
    end
  end
end