require "spec_helper"
require "seedie"
require "rails_helper"

describe Seedie::ModelFields do
  let(:model_config) { {} }
  let(:model) { User }

  describe "#initialize" do
    context "when attributes are provided in model_config" do
      let(:model_config) { { "attributes" => { "name" => "John", "email" => "john@example.com" } } }

      it "sets custom_fields to the keys of the attributes hash" do
        model_fields = described_class.new(model, model_config)
        expect(model_fields.instance_variable_get(:@custom_fields)).to eq %w[name email]
      end
    end

    context "when disabled_fields are provided in model_config" do
      let(:model_config) { { "disabled_fields" => %w[name] } }

      it "appends disabled_fields to DEFAULT_DISABLED_FIELDS" do
        model_fields = described_class.new(model, model_config)
        expect(model_fields.instance_variable_get(:@disabled_fields)).to eq %w[name id created_at updated_at]
      end
    end

    context "when attributes and disabled_fields are not provided in model_config" do
      it "sets other_fields to the column names excluding DEFAULT_DISABLED_FIELDS" do
        model_fields = described_class.new(model, model_config)
        expect(model_fields.instance_variable_get(:@other_fields)).to eq(%w[name email password password_digest
                                                                            nickname address])
      end
    end
  end
end
