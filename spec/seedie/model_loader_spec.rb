require "spec_helper"
require "rails_helper"
require "seedie"

describe Seedie::ModelLoader do
  let(:model) { User }
  let(:model_config) { {} }
  let(:config) { {} }
  let(:field_values_set) { double(:field_values_set, generate_field_values: {}) }

  subject { described_class.new(model, model_config, config) }

  before do
    allow(Seedie::FieldValuesSet).to receive(:new).and_return(field_values_set)
  end
  
  describe "#generate_records" do
    context "when count is specified in model_config" do
      let(:model_config) { {"count" => 2} }

      it "generates the specified number of records" do
        subject.generate_records

        expect(model.count).to eq 2
      end
    end

    context "when default_count is specified in config" do
      let(:config) { {"default_count" => 3} }

      it "generates the default number of records" do
        subject.generate_records

        expect(model.count).to eq 3
      end
    end

    context "when count is not specified" do
      it "generates one record" do
        subject.generate_records

        expect(model.count).to eq 1
      end
    end

    context "when associations are specified in model_config" do
      let(:model) { Post }
      let(:model_config) { {"associations" => {"comments" => {"count" => 2}}} }

      it "generates the specified number of associations" do
        subject.generate_records

        expect(model.first.comments.count).to eq 2
      end
    end
  end
end
