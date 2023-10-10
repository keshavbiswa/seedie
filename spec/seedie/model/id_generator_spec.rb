# frozen_string_literal: true

require "seedie"
require "rails_helper"

RSpec.describe Seedie::Model::IdGenerator do
  let(:model) { User }
  let(:field_values_set) { { name: "name 0", email: "email 0", password: "password 0" } }

  subject { described_class.new(model) }

  describe "#random_id" do
    context "when there are records" do
      let!(:user) { User.create!(name: "name 0", email: "email 0", password: "password 0") }
      let!(:user2) { User.create!(name: "name 1", email: "email 1", password: "password 1") }

      it "returns a random id" do
        expect(subject.random_id).to be_in([user.id, user2.id])
      end
    end

    context "when there are no records" do
      it "raises InvalidAssociationConfigError" do
        expect {
          subject.random_id
        }.to raise_error(Seedie::InvalidAssociationConfigError, "User has no records")
      end
    end
  end

  describe "#unique_id_for" do
    subject { described_class.new(Post) }

    context "when there are unique records" do
      let!(:post1) { Post.create!(title: "title 0", content: "body 0") }
      let!(:post2) { Post.create!(title: "title 1", content: "body 1") }

      it "returns a unique id" do
        expect(subject.unique_id_for(Comment, "post_id")).to be_in([post1.id, post2.id])
      end
    end

    context "when there are no records" do
      it "raises InvalidAssociationConfigError" do
        expect {
          subject.unique_id_for(Comment, "post_id")
        }.to raise_error(Seedie::InvalidAssociationConfigError, "No unique ids for Post")
      end
    end
  end
end
