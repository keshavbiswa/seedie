require "seedie"
require "rails_helper"

RSpec.describe Seedie::Associations::HasMany do
  let(:record) { Post.create! }
  let(:model) { record.class }
  let(:model_config) {
    { "has_many" => {
      "comments" => 4
    } }
  }
  let(:field_values_set) { { "field" => "value" } }

  describe "#generate_associations" do
    subject { described_class.new(record, model, model_config) }

    context "when the association config is a string (indicating count)" do
      it "generates the correct number of associations" do
        subject.generate_associations

        expect(record.comments.count).to eq(4)
        expect(record.comments.first).to be_a(Comment)
      end
    end

    context "when the association config is a hash with count key" do
      let(:model_config) {
        { "has_many" => {
          "comments" => { "count" => 3 }
        } }
      }

      it "generates the correct number of associations" do
        subject.generate_associations

        expect(record.comments.count).to eq(3)
        expect(record.comments.first).to be_a(Comment)
      end
    end

    context "when the association config is a hash without count key" do
      let(:model_config) do
        {
          "has_many" => {
            "comments" => {
              "attributes" => {
                "content" => "Some content with index: {{index}}"
              }
            }
          }
        }
      end

      it "generates one association" do
        subject.generate_associations

        expect(record.comments.count).to eq(1)
        expect(record.comments.first.content).to eq("Some content with index: 0")
      end
    end
  end
end
