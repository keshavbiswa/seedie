require "spec_helper"
require "seedie"

describe Seedie::FieldValues::FakeValue do
  let(:name) { "name" }
  let(:column) { instance_double("column") }
  let(:fake_value) { described_class.new(name, column) }

  describe "#generate_fake_value" do
    context "when column type is string" do
      it "returns a faker word" do
        allow(column).to receive(:type).and_return(:string)
        allow(Faker::Lorem).to receive(:word).and_return("random_word")
        
        expect(fake_value.generate_fake_value).to eq("random_word")
      end
    end

    context "when column type is text" do
      it "returns a faker paragraph" do
        allow(column).to receive(:type).and_return(:text)
        allow(Faker::Lorem).to receive(:paragraph).and_return("random_paragraph")

        expect(fake_value.generate_fake_value).to eq("random_paragraph")
      end
    end

    context "when column type is integer" do
      it "returns a faker number" do
        allow(column).to receive(:type).and_return(:integer)
        allow(Faker::Number).to receive(:number).with(digits: 2).and_return(45)

        expect(fake_value.generate_fake_value).to eq(45)
      end
    end

    context "when column type is datetime" do
      it "returns a faker time between now and 1 day ago" do
        time_now = DateTime.now
        time_one_day_ago = DateTime.now - 1
        fake_time = Faker::Time.between(from: time_one_day_ago, to: time_now)

        allow(DateTime).to receive(:now).and_return(time_now)
        allow(column).to receive(:type).and_return(:datetime)
        allow(Faker::Time).to receive(:between).with(from: time_one_day_ago, to: time_now).and_return(fake_time)

        expect(fake_value.generate_fake_value).to eq(fake_time)
      end
    end

    context "when column type is boolean" do
      it "returns a faker boolean" do
        allow(column).to receive(:type).and_return(:boolean)
        allow(Faker::Boolean).to receive(:boolean).and_return(true)

        expect(fake_value.generate_fake_value).to eq(true)
      end
    end

    context "when column type is unknown" do
      it "raises an error" do
        allow(column).to receive(:type).and_return(:unknown)

        expect {
 fake_value.generate_fake_value }.to raise_error(Seedie::UnknownColumnTypeError, "Unknown column type: unknown")
      end
    end
  end
end
