require "seedie"
require "rails_helper"

RSpec.describe Seedie::Model::Creator do
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
end