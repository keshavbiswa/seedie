require "rails_helper"

RSpec.describe Seedie::FieldValues::FakerBuilder do
  
  describe "#build_faker_constant" do
    context "when column type is unknown" do
      let(:column) { double("column", type: :unknown) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "raises an error" do
        expect { faker_builder.build_faker_constant }.to raise_error(Seedie::UnknownColumnTypeError)
      end
    end

    context "when column type is :string" do
      let(:column) { double("column", type: :string) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Lorem.word}}")
      end
    end

    context "when column type is :uuid" do
      let(:column) { double("column", type: :uuid) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Internet.uuid}}")
      end
    end

    context "when column type is :integer" do
      let(:column) { double("column", type: :integer) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Number.number(digits: 5)}}")
      end
    end

    context "when column type is :decimal" do
      let(:column) { double("column", type: :decimal) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Number.decimal(l_digits: 2, r_digits: 2)}}")
      end
    end

    context "when column type is :datetime" do
      let(:column) { double("column", type: :datetime) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expected_output = "{{Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)}}"
        expect(faker_builder.build_faker_constant).to eq(expected_output)
      end
    end

    context "when column type is :date" do
      let(:column) { double("column", type: :date) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expected_output = "{{Faker::Date.between(from: Date.today - 1, to: Date.today)}}"
        expect(faker_builder.build_faker_constant).to eq(expected_output)
      end
    end

    context "when column type is :boolean" do
      let(:column) { double("column", type: :boolean) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Boolean.boolean}}")
      end
    end

    context "when column type is :json" do
      let(:column) { double("column", type: :json) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        output = "{{Faker::Json.shallow_json(width: 3, options: { key: \"Name.first_name\", value: \"Number.number(digits: 2)\" })}}"
        expect(faker_builder.build_faker_constant).to eq(output)
      end
    end

    context "when column type is :inet" do
      let(:column) { double("column", type: :inet) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Internet.ip_v4_address}}")
      end
    end

    context "when column type is :cidr" do
      let(:column) { double("column", type: :cidr) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Internet.mac_address}}")
      end
    end

    context "when column type is :bytea" do
      let(:column) { double("column", type: :bytea) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Internet.password}}")
      end
    end

    context "when column type is :bit" do
      let(:column) { double("column", type: :bit) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Internet.password}}")
      end
    end

    context "when column type is :money" do
      let(:column) { double("column", type: :money) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Commerce.price.to_s}}")
      end
    end

    context "when column type is :hstore" do
      let(:column) { double("column", type: :hstore) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expected_output = "{{Faker::Json.shallow_json(width: 3, options: { key: \"Name.first_name\", value: \"Number.number(digits: 2)\" })}}"

        expect(faker_builder.build_faker_constant).to eq(expected_output)
      end
    end

    context "when column type is :year" do
      let(:column) { double("column", type: :year) }
      let(:validations) { [] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Number.number(digits: 4)}}")
      end
    end

    context "when column has uniqueness validation" do
      let(:column) { double("column", type: :string) }
      let(:validations) { [double("validation", kind: :uniqueness)] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression with unique prefix" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Lorem.unique.word}}")
      end
    end

    context "when column has inclusion validation" do
      let(:column) { double("column", type: :string) }
      let(:validations) { [double("validation", kind: :inclusion, options: { in: ["foo", "bar"] })] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression with inclusion options" do
        expect(faker_builder.build_faker_constant).to eq("{{[\"foo\", \"bar\"]}}")
      end
    end

    context "when column has numericality validation with range" do
      let(:column) { double("column", type: :integer) }
      let(:validations) {
 [double("validation", kind: :numericality, options: { greater_than_or_equal_to: 10, less_than_or_equal_to: 20 })] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression with numericality options" do
        expected_output = "{{Faker::Number.number(digits: 5).between(from: 10, to: 20)}}"
        expect(faker_builder.build_faker_constant).to eq(expected_output)
      end
    end

    context "when column has numericality validation with minimum" do
      let(:column) { double("column", type: :integer) }
      let(:validations) { [double("validation", kind: :numericality, options: { greater_than_or_equal_to: 10 })] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression with numericality options" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Number.number(digits: 5).between(from: 10)}}")
      end
    end

    context "when column has numericality validation with maximum" do
      let(:column) { double("column", type: :integer) }
      let(:validations) { [double("validation", kind: :numericality, options: { less_than_or_equal_to: 20 })] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression with numericality options" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Number.number(digits: 5).between(to: 20)}}")
      end
    end

    context "when column has length validation with range" do
      let(:column) { double("column", type: :string) }
      let(:validations) { [double("validation", kind: :length, options: { minimum: 5, maximum: 10 })] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression with length options" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Lorem.characters(number: rand(5..10))}}")
      end
    end

    context "when column has length validation with minimum" do
      let(:column) { double("column", type: :string) }
      let(:validations) { [double("validation", kind: :length, options: { minimum: 5 })] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression with length options" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Lorem.characters(number: rand(5..100))}}")
      end
    end

    context "when column has length validation with maximum" do
      let(:column) { double("column", type: :string) }
      let(:validations) { [double("validation", kind: :length, options: { maximum: 10 })] }
      let(:faker_builder) { described_class.new("name", column, validations) }

      it "returns a valid Faker expression with length options" do
        expect(faker_builder.build_faker_constant).to eq("{{Faker::Lorem.characters(number: rand(1..10))}}")
      end
    end
  end
end