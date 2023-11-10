# frozen_string_literal: true

require "rails_helper"

RSpec.describe Seedie::Associations::HasAndBelongsToMany do
  let(:record) { User.create!(name: "test", email: "test@example.com", password: "password") }
  let(:model) { record.class }
  let(:model_config) do
    {
      "has_and_belongs_to_many" => {
        "boards" => 4
      }
    }
  end

  describe "#generate_associations" do
    subject { described_class.new(record, model, model_config) }

    context "when the association config is a string (indicating count)" do
      it "generates the correct number of associations" do
        subject.generate_associations

        expect(record.boards.count).to eq(4)
        expect(record.boards.first).to be_a(Board)
      end
    end

    context "when the association config is a hash" do
      let(:model_config) do
        {
          "has_and_belongs_to_many" => {
            "boards" => {
              "count" => 3,
              "attributes" => {
                "name" => "Name: {{index}}"
              }
            }
          }
        }
      end

      it "generates one association" do
        subject.generate_associations

        expect(record.boards.count).to eq(3)
        expect(record.boards.first.name).to eq("Name: 0")
      end
    end
  end
end
