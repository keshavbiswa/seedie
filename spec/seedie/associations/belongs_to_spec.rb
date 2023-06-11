require "rails_helper"
require "seedie"

RSpec.describe Seedie::Associations::BelongsTo do
  let(:model) { Comment }
  let(:association_config) do
    {
      "belongs_to" => {
        "post" => {
          "attributes" => {
            "title" => "Post {{index}}"
          }
        }
      }
    }
  end

  subject { described_class.new(model, association_config) }

  describe "#generate_associations" do
    context "when the association config is a string (indicating count)" do
      context "when count is 1" do
        let(:association_config) { { "belongs_to" => { "post" => 1 } } }

        it "generates the correct number of associations" do
          subject.generate_associations

          expect(Post.count).to eq(1)
          expect(Post.first).to be_a(Post)
        end
      end

      context "when count is greater than 1" do
        let(:association_config) { { "belongs_to" => { "post" => 2 } } }

        it "raises InvalidAssociationConfigError" do
          expect {
            subject.generate_associations
          }.to raise_error(Seedie::InvalidAssociationConfigError, "belongs_to association cannot be more than 1")
        end
      end
    end

    context "when the association config is a hash" do
      it "generates one association" do
        subject.generate_associations

        expect(Post.count).to eq(1)
        expect(Post.first.title).to eq("Post 0")
      end
    end
  end
end