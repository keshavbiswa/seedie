require "spec_helper"
require "seedie"

describe Seedie::FieldValues::CustomValue do
  let(:name) { "name" }
  let(:value_template) { "value_template{{index}}" }
  let(:index) { 1 }
  let(:custom_value) { described_class.new(name, value_template, index) }

  describe "#generate_custom_field_value" do
    before do
      allow(Faker::Name).to receive(:name).and_return("custom_name")
      allow(Faker::Internet).to receive(:email).and_return("custom_email")
    end

    context "when the value_template is a string" do
      context "when the value_template contains {{index}}" do
        it "returns the value_template with index interpolated" do
          expect(custom_value.generate_custom_field_value).to eq("value_template1")
        end
      end

      context "when the value_template contains faker values" do
        let(:value_template) { "value_template{{index}} {{Faker::Name.name}} {{Faker::Internet.email}}" }
        
        it "returns whatever value_template with faker values set" do
          expect(custom_value.generate_custom_field_value).to eq("value_template1 custom_name custom_email")
        end
      end

      context "when the value_template contains non faker method" do
        let(:value_template) { "value_template{{index}} {{NotFaker::Name.name}}" }
        
        it "raises an error" do
          expect {
            custom_value.generate_custom_field_value 
          }.to raise_error(Seedie::InvalidFakerMethodError, "Invalid method: NotFaker::Name.name")
        end
      end

      context "when the value_template contains invalid faker method" do
        let(:value_template) { "value_template {{Faker::SomeInvalidMethod.name}}" }
        
        it "raises an error" do
          expect { custom_value.generate_custom_field_value }.to raise_error(NameError)
        end
      end
    end
  end
end