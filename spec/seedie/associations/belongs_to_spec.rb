# frozen_string_literal: true

require "rails_helper"
require "seedie"

RSpec.describe Seedie::Associations::BelongsTo do
  let(:model) { Comment }

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
            expect do
              subject.generate_associations
            end.to raise_error(Seedie::InvalidAssociationConfigError, "Post has no records")
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
      context "when the association is a polymorphic association" do
        let!(:user) { User.create(name: "User 1", email: "test@example.com", password: "password") }
        let!(:post) { Post.create!(title: "Post 1") }
        let!(:post2) { Post.create!(title: "Post 2") }
        let!(:game_room) { GameRoom.create!(name: "Game Room 1", creator: user, updater: user) }
        let!(:game_room2) { GameRoom.create!(name: "Game Room 2", creator: user, updater: user) }

        let(:model) { Review }
        let(:association_config) do
          {
            "belongs_to" => {
              "user" => "random",
              "reviewable" => {
                "polymorphic" => "post"
              }
            }
          }
        end

        context "when there is only one polymorphic type given" do
          it "assigns the polymorphic association to the associated_field_set" do
            subject.generate_associations

            expect(subject.associated_field_set["reviewable_id"]).to be_in([post.id, post2.id])
            expect(subject.associated_field_set["reviewable_type"]).to eq("Post")
          end
        end

        context "when there is an array of polymorphic types given" do
          let(:association_config) do
            {
              "belongs_to" => {
                "reviewable" => {
                  "polymorphic" => %w[post game_room]
                }
              }
            }
          end

          it "randomly assigns the polymorphic association to the associated_field_set" do
            subject.generate_associations

            expect(subject.associated_field_set["reviewable_id"]).to be_in([post.id, post2.id, game_room.id, game_room2.id])
            expect(subject.associated_field_set["reviewable_type"]).to be_in(%w[Post GameRoom])
          end
        end

        context "when strategy is random" do
          before do
            association_config["belongs_to"]["reviewable"]["strategy"] = "random"
          end

          it "assigns randomly the polymorphic association to the associated_field_set" do
            subject.generate_associations

            expect(subject.associated_field_set["reviewable_id"]).to be_in([post.id, post2.id])
            expect(subject.associated_field_set["reviewable_type"]).to eq("Post")
          end
        end

        context "when strategy is unique" do
          before do
            association_config["belongs_to"]["reviewable"]["strategy"] = "unique"
          end

          it "uniquely assigns the polymorphic association to the associated_field_set" do
            generated_associations = []

            2.times do
              subject.generate_associations
              new_record = model.create!(subject.associated_field_set)
              generated_associations << new_record.reviewable_id
            end

            expect(generated_associations.uniq.length).to eq(generated_associations.length)
          end
        end

        context "when strategy is new" do
          before do
            association_config["belongs_to"]["reviewable"]["strategy"] = "new"
          end

          it "creates a new polymorphic association" do
            expect { subject.generate_associations }.to change { Post.count }.by(1)
          end
        end
      end

      context "when the association has attributes" do
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

        it "generates one association" do
          subject.generate_associations

          expect(Post.count).to eq(1)
          expect(Post.first.title).to eq("New Post 0")
        end
      end
    end
  end
end
