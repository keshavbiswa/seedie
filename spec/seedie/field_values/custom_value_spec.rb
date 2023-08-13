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

    context "when the value_template is a hash" do
      context "when keys are invalid" do
        let (:value_template) { { "SomeInvalid key" => "value" } }
        
        it "raises an error" do
          message = "Invalid keys for name: SomeInvalid key. Only [\"values\", \"value\", \"options\"] are allowed."
          expect {
            custom_value.generate_custom_field_value
          }.to raise_error(Seedie::InvalidCustomFieldKeysError, message)
        end
      end

      context "when value key is present" do
        let (:value_template) { { "value" => "value" } }

        it "returns the value" do
          expect(custom_value.generate_custom_field_value).to eq("value")
        end
      end

      context "when both values and value keys are present" do
        let (:value_template) { { "values" => ["value1", "value2"], "value" => "value" } }

        it "raises an error" do
          message = "Invalid keys for name: values and value cannot be used together."
          expect {
            custom_value.generate_custom_field_value
          }.to raise_error(Seedie::InvalidCustomFieldKeysError, message)
        end
      end

      context "when values key is not an array or a hash" do
        let (:value_template) { { "values" => "value" } }

        it "raises an error" do
          message = "The values key for name must be an array or a hash with start and end keys."
          expect {
            custom_value.generate_custom_field_value
          }.to raise_error(Seedie::InvalidCustomFieldValuesError, message)
        end
      end

      context "when values key is a hash" do
        context "when values hash does not have start and end keys" do
          let (:value_template) { { "values" => { "invalid_key" => "value" } } }

          it "raises an error" do
            message = "The values key for name must be an array or a hash with start and end keys."
            expect {
              custom_value.generate_custom_field_value
            }.to raise_error(Seedie::InvalidCustomFieldValuesError, message)
          end
        end

        context "when values hash has start and end keys" do
          let (:value_template) { { "values" => { "start" => 1, "end" => 3 } } }

          it "returns a random value from the given range" do
            expect((1..3)).to include(custom_value.generate_custom_field_value)
          end
        end
      end

      context "when pick_strategy is sequential" do
        context "when values is an array" do
          let(:value_template) { { "values" => ["value1", "value2"], "options" => { "pick_strategy" => "sequential" } } }
          
          context "when values is less than index" do
            let(:index) { 3 }

            it "raises an error" do
              message = "There are not enough values for name. Please add more values."
              expect {
                custom_value.generate_custom_field_value
              }.to raise_error(Seedie::CustomFieldNotEnoughValuesError, message)
            end
          end

          it "returns a sequential value from the given array" do
            custom_value = described_class.new(name, value_template, 0)
            expect(custom_value.generate_custom_field_value).to eq("value1")
  
            custom_value = described_class.new(name, value_template, 1)
            expect(custom_value.generate_custom_field_value).to eq("value2")
          end
        end

        context "when values is a hash" do
          let(:value_template) { { "values" => { "start" => 1, "end" => 3 }, "options" => { "pick_strategy" => "sequential" } } }
          
          context "when values is less than index" do
            let(:index) { 3 }

            it "raises an error" do
              message = "There are not enough values for name. Please add more values."
              expect {
                custom_value.generate_custom_field_value
              }.to raise_error(Seedie::CustomFieldNotEnoughValuesError, message)
            end
          end

          it "returns a sequential value from the start and end range" do
            custom_value = described_class.new(name, value_template, 0)
            expect(custom_value.generate_custom_field_value).to eq(1)
  
            custom_value = described_class.new(name, value_template, 1)
            expect(custom_value.generate_custom_field_value).to eq(2)
          end
        end


      end

      context "when pick_strategy is random" do
        let(:value_template) { { "values" => ["value1", "value2"], "options" => { "pick_strategy" => "random" } } }
        it "returns a random value from the given array" do
          
          custom_value = described_class.new(name, value_template, 0)

          expect((["value1", "value2"])).to include(custom_value.generate_custom_field_value)
        end
      end

      context "when pick_strategy is invalid" do
        let(:value_template) { { "values" => ["value1", "value2"], "options" => { "pick_strategy" => "invalid" } } }

        it "raises an error" do
          message = "The pick_strategy for name must be either 'sequential' or 'random'."

          expect {
            custom_value.generate_custom_field_value
          }.to raise_error(Seedie::InvalidCustomFieldOptionsError, message)
        end
      end
    end
  end
end