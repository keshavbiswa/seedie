require "spec_helper"
require "rails_helper"

RSpec.describe Seedie::FieldValues::ValueTemplateValidator do
  let(:name) { "name" }
  let(:value_template) { "value_template{{index}}" }
  let(:index) { 1 }

  describe "#validate" do
    let(:subject) { described_class.new(value_template, index, name) }

    context "when the value template is not a hash" do
      it "does not raise an error" do
        expect { subject.validate }.not_to raise_error
      end
    end

    context "when the value template is a hash" do
      context "when the value template has invalid keys" do
        let(:value_template) { { "SomeInvalid key" => "value" } }
        let(:subject) { described_class.new(value_template, index, name) }

        it "raises an error" do
          message = "Invalid keys for name: SomeInvalid key. Only [\"values\", \"value\", \"options\"] are allowed."
          expect { subject.validate }.to raise_error(Seedie::InvalidCustomFieldKeysError, message)
        end
      end

      context "when the value template has both values and value keys" do
        let(:value_template) { { "values" => [], "value" => "value" } }
        subject { described_class.new(value_template, index, name) }

        it "raises an error" do
          message = "Invalid keys for name: values and value cannot be used together."
          expect { subject.validate }.to raise_error(Seedie::InvalidCustomFieldKeysError, message)
        end
      end

      context "when the value template has values key" do
        context "when the values key is not an array or a hash" do
          let(:value_template) { { "values" => "value" } }
          subject { described_class.new(value_template, index, name) }

          it "raises an error" do
            message = "The values key for name must be an array or a hash with start and end keys."
            expect { subject.validate }.to raise_error(Seedie::InvalidCustomFieldValuesError, message)
          end
        end

        context "when the values key is an array" do
          let(:value_template) { { "values" => ["value1", "value2"] } }
          subject { described_class.new(value_template, index, name) }

          it "does not raise an error" do
            expect { subject.validate }.not_to raise_error
          end
        end

        context "when the values key is a hash" do
          context "when the values hash does not have start and end keys" do
            let(:value_template) { { "values" => { "invalid_key" => "value" } } }
            subject { described_class.new(value_template, index, name) }

            it "raises an error" do
              message = "The values key for name must be an array or a hash with start and end keys."
              expect { subject.validate }.to raise_error(Seedie::InvalidCustomFieldValuesError, message)
            end
          end

          context "when the values hash has start and end keys" do
            let(:value_template) { { "values" => { "start" => 1, "end" => 3 } } }
            subject { described_class.new(value_template, index, name) }

            it "does not raise an error" do
              expect { subject.validate }.not_to raise_error
            end
          end
        end
      end
    end

    context "when the value template has options key" do
      context "when the pick_strategy is invalid" do
        let(:value_template) { { "options" => { "pick_strategy" => "invalid_strategy" } } }
        subject { described_class.new(value_template, index, name) }

        it "raises an error" do
          message = "The pick_strategy for name must be either 'sequential' or 'random'."
          expect { subject.validate }.to raise_error(Seedie::InvalidCustomFieldOptionsError, message)
        end
      end

      context "when the pick_strategy is valid" do
        let(:value_template) { { "options" => { "pick_strategy" => "random" } } }
        subject { described_class.new(value_template, index, name) }

        it "does not raise an error" do
          expect { subject.validate }.not_to raise_error
        end
      end
    end
  end
end
