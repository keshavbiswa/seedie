require "rails_helper"
require "seedie"

RSpec.describe Seedie::Associations::BelongsTo do
  let(:model) { Comment }
  let(:association_config) do
    {
      "belongs_to" => {
        "post" => {
          "attributes" => {
            "title" => "New Post {{index}}"
          }
        }
      }
    }
  end

  subject { described_class.new(model, association_config) }

  describe "#generate_associations" do
    context "when the association config is a string" do
      context "when config says random" do
        let(:association_config) { { "belongs_to" => { "post" => "random" } } }

        context "when post exists" do
          let!(:post) { Post.create!(title: "Post 1") }
          let!(:post2) { Post.create!(title: "Post 2") }

          it "generates associates the comment to a random post" do
            subject.generate_associations

            expect(subject.associated_field_set["post_id"]).to be_in([post.id, post2.id])
          end
        end

        context "when post does not exist" do
          it "raises InvalidAssociationConfigError" do
            expect {
              subject.generate_associations
            }.to raise_error(Seedie::InvalidAssociationConfigError, "Post has no records")
          end
        end
      end

      context "when config says new" do
        let(:association_config) { { "belongs_to" => { "post" => "new" } } }

        it "generates a new post" do
          subject.generate_associations

          expect(Post.count).to eq(1)
        end
      end
    end

    context "when the association config is a hash" do
      it "generates one association" do
        subject.generate_associations

        expect(Post.count).to eq(1)
        expect(Post.first.title).to eq("New Post 0")
      end
    end
  end
end