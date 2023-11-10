# frozen_string_literal: true

require "rails_helper"
require "seedie"

describe Seedie::ModelSeeder do
  let(:model) { User }
  let(:model_config) { {} }
  let(:config) { {} }
  let(:reporters) { [] }

  subject { described_class.new(model, model_config, config, reporters) }

  describe "#generate_records" do
    context "when count is specified in model_config" do
      let(:model_config) { { "count" => 2, "attributes" => { "email" => "{{Faker::Internet.unique.email}}" } } }

      it "generates the specified number of records" do
        subject.generate_records

        expect(model.count).to eq 2
      end
    end

    context "when default_count is specified in config" do
      let(:config) do
        { "default_count" => 3,
          "models" => { "user" => { "attributes" => { "email" => "{{Faker::Internet.unique.email}}" } } } }
      end

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
      let(:model_config) do
        { "associations" =>
          {
            "has_many" => {
              "comments" => { "count" => 2 }
            },
            "has_one" => {
              "post_metadatum" => { "count" => 1 }
            }
          } }
      end

      it "generates the specified number of associations" do
        subject.generate_records

        expect(model.first.comments.count).to eq 2
        expect(model.first.post_metadatum).to be_present
      end
    end

    context "when belongs_to associations are specified in model_config" do
      let(:model) { Comment }
      let(:model_config) do
        { "associations" =>
          {
            "belongs_to" => {
              "post" => { "attributes" => { "title" => "Post {{index}}" } }
            }
          } }
      end

      it "generates the specified number of associations" do
        subject.generate_records

        expect(model.first.post).to be_present
        expect(model.first.post.title).to eq "Post 0"
      end
    end
  end
end
