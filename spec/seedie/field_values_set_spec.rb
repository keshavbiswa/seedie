require "spec_helper"
require "seedie"
require "rails_helper"

describe Seedie::FieldValuesSet do
  let(:model) { Comment }
  let(:model_config) { {} }
  let(:index) { 1 }

  subject { described_class.new(model, model_config, index) }

  describe "#generate_field_values" do
    it "excludes disabled_fields" do
      model_config["disabled_fields"] = ["content"]
      expect(subject.generate_field_values).to eq({})
    end

    it "excludes foreign_fields" do
      model_config["attributes"] = { "content" => "comment {{index}}" }

      expect(subject.generate_field_values.keys).not_to include("post_id")
    end

    it "generates custom value" do
      model_config["attributes"] = { "content" => "custom name" }

      expect(subject.generate_field_values).to eq({ "content" => "custom name" })
    end

    it "generates fake value" do
      model_config["attributes"] = {}

      expect(subject.generate_field_values["content"]).to be_a(String)
    end

    it "generates values for virtual fields" do
      model_config["attributes"] = { "virtual_field" => "Virtual Field Value" }

      expect(subject.generate_field_values).to include({ "virtual_field" => "Virtual Field Value" })
    end
  end

  describe "#generate_field_values_with_associations" do
    before do
      Post.create!(title: "Post Title")
    end

    it "generates values for belongs_to associations" do
      model_config["associations"] = { "belongs_to" => { "post" => "random" } }

      expect(subject.generate_field_values_with_associations).to include({ "post_id" => 1 })
    end
  end
end
