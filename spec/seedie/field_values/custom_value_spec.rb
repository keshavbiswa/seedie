require 'spec_helper'
require "seedie"

describe Seedie::FieldValues::CustomValue do
  let(:name) { 'name' }
  let(:value_template) { "value_template{{index}}" }
  let(:index) { 1 }
  let(:custom_value) { described_class.new(name, value_template, index) }

  describe '#generate_custom_field_value' do
    before do
      allow(Faker::Name).to receive(:name).and_return('custom_name')
      allow(Faker::Internet).to receive(:email).and_return('custom_email')
    end

    it 'returns the value_template with index interpolated' do
      expect(custom_value.generate_custom_field_value).to eq("value_template1")
    end

    it "returns whatever value_template with faker values set" do
      value_template = "value_template{{index}} {{Faker::Name.name}} {{Faker::Internet.email}}"

      custom_value = described_class.new(name, value_template, index)

      expect(custom_value.generate_custom_field_value).to eq("value_template1 custom_name custom_email")
    end

    it "raises an error if the method is not Faker" do
      value_template = "value_template{{index}} {{NotFaker::Name.name}}"
      custom_value = described_class.new(name, value_template, index)

      expect { custom_value.generate_custom_field_value }.to raise_error(Seedie::InvalidFakerMethodError, "Invalid method: NotFaker::Name.name")
    end

    it "raises an error if the Faker method is invalid" do
      value_template = "value_template {{Faker::SomeInvalidMethod.name}}"
      custom_value = described_class.new(name, value_template, index)

      expect { custom_value.generate_custom_field_value }.to raise_error(NameError)
    end
  end
end