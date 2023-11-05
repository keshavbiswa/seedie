require "rails_helper"
require "seedie"

RSpec.describe Seedie::Associations::HasOne do
  let(:record) { Post.create! }
  let(:model) { Post }
  let(:association_config) do
    {
      "has_one" => {
        "post_metadatum" => {
          "attributes" => {
            "seo_text" => "PostMetadatum {{index}}"
          }
        }
      }
    }
  end

  subject { described_class.new(record, model, association_config) }

  describe "#generate_associations" do
    context "when the association config is a string (indicating count)" do
      context "when count is 1" do
        let(:association_config) { { "has_one" => { "post_metadatum" => 1 } } }

        it "generates the correct number of associations" do
          subject.generate_associations

          expect(record.post_metadatum).to be_a(PostMetadatum)
          expect(record.post_metadatum.persisted?).to eq(true)
        end
      end

      context "when count is greater than 1" do
        let(:association_config) { { "has_one" => { "post_metadatum" => 2 } } }

        it "raises InvalidAssociationConfigError" do
          expect {
            subject.generate_associations
          }.to raise_error(Seedie::InvalidAssociationConfigError, "has_one association cannot be more than 1")
        end
      end
    end

    context "when the association config is a hash" do
      let(:config) { { "has_one" => { "post_metadatum" => { "attributes" => { "seo_text" => "PostMetadatum {{index}}" } } } } }

      it "generates one association" do
        subject.generate_associations

        expect(record.post_metadatum).to be_a(PostMetadatum)
        expect(record.post_metadatum.seo_text).to eq("PostMetadatum 0")
      end
    end
  end
end
