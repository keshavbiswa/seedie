require "rails_helper"

RSpec.describe Seedie::RecordCreator do
  let(:model) { User }
  let(:field_values_set) { { name: "name 0", email: "email 0", address: "address 0" } }

  subject { described_class.new(model) }

  describe "#create!" do
    it "creates a new record" do
      expect {
        subject.create!(field_values_set)
      }.to change { User.count }.by(1)
    end

    it "returns the created record" do
      expect(subject.create!(field_values_set)).to be_a(User)
    end
  end

  describe "#create" do
    context "when the record is valid" do
      it "creates a new record" do
        expect {
          subject.create(field_values_set)
        }.to change { User.count }.by(1)
      end

      it "returns the created record" do
        expect(subject.create(field_values_set)).to be_a(User)
      end
    end

    context "when the record is invalid" do
      before do
        allow(User).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "does not create a new record" do
        expect {
          subject.create(field_values_set)
        }.not_to change { User.count }
      end

      it "returns nil" do
        expect(subject.create(field_values_set)).to be_nil
      end
    end
  end

  describe "#get_random_id" do
    context "when there are records" do
      let!(:user) { User.create!(name: "name 0", email: "email 0", address: "address 0") }
      let!(:user2) { User.create!(name: "name 1", email: "email 1", address: "address 1") }

      it "returns a random id" do
        expect(subject.get_random_id).to be_in([user.id, user2.id])
      end
    end

    context "when there are no records" do
      it "raises InvalidAssociationConfigError" do
        expect {
          subject.get_random_id
        }.to raise_error(Seedie::InvalidAssociationConfigError, "User does not exist")
      end
    end
  end
end