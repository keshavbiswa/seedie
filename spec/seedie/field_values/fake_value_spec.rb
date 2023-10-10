# frozen_string_literal: true

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
        allow(Faker::Lorem).to receive(:word).and_return("random_text")

        expect(fake_value.generate_fake_value).to eq("random_text")
      end
    end

    context "when column type is integer" do
      it "returns a faker number" do
        allow(column).to receive(:type).and_return(:integer)
        allow(Faker::Number).to receive(:number).with(digits: 5).and_return(45)

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

    context "when column type is uuid" do
      it "returns a SecureRandom.uuid" do
        allow(column).to receive(:type).and_return(:uuid)
        allow(SecureRandom).to receive(:uuid).and_return("uuid")

        expect(fake_value.generate_fake_value).to eq("uuid")
      end
    end

    context "when column type is decimal, float or real" do
      it "returns a faker decimal" do
        allow(column).to receive(:type).and_return(:decimal)
        allow(Faker::Number).to receive(:decimal).with(l_digits: 2, r_digits: 2).and_return(45.45)

        expect(fake_value.generate_fake_value).to eq(45.45)
      end
    end

    context "when column type is date" do
      it "returns a faker date between 2 days ago and today" do
        date_today = Date.today
        date_two_days_ago = Date.today - 2

        allow(Date).to receive(:today).and_return(date_today)
        allow(column).to receive(:type).and_return(:date)
        allow(Faker::Date).to receive(:between).with(from: date_two_days_ago, to: date_today).and_return(date_today)

        expect(fake_value.generate_fake_value).to eq(date_today)
      end
    end

    context "when column type is time or timez" do
      it "returns a faker time" do
        allow(column).to receive(:type).and_return(:time)
        allow(Faker::Time).to receive(:forward).with(days: 23, period: :morning).and_return("time")

        expect(fake_value.generate_fake_value).to eq("time")
      end
    end

    context "when column type is json or jsonb" do
      it "returns a faker json" do
        allow(column).to receive(:type).and_return(:json)
        allow(Faker::Lorem).to receive(:word).and_return("random_text")
        allow(Faker::Number).to receive(:number).with(digits: 2).and_return(2)

        result = { "value": { "key1": "random_text", "key2": 2 } }
        expect(fake_value.generate_fake_value.to_json).to eq(result.to_json)
      end
    end

    context "when column type is inet" do
      it "returns a faker ip address" do
        allow(column).to receive(:type).and_return(:inet)
        allow(Faker::Internet).to receive(:ip_v4_address).and_return("ip_address")

        expect(fake_value.generate_fake_value).to eq("ip_address")
      end
    end

    context "when column type is cidr or macaddr" do
      it "returns a faker mac address" do
        allow(column).to receive(:type).and_return(:cidr)
        allow(Faker::Internet).to receive(:mac_address).and_return("mac_address")

        expect(fake_value.generate_fake_value).to eq("mac_address")
      end
    end

    context "when column type is bytea" do
      it "returns a faker password" do
        allow(column).to receive(:type).and_return(:bytea)
        allow(Faker::Internet).to receive(:password).and_return("password")

        expect(fake_value.generate_fake_value).to eq("password")
      end
    end

    context "when column type is bit or bit_varying" do
      it "returns a bit" do
        allow(column).to receive(:type).and_return(:bit)

        expect(["1", "0"]).to include(fake_value.generate_fake_value)
      end
    end

    context "when column type is money" do
      it "returns a faker money" do
        allow(column).to receive(:type).and_return(:money)
        allow(Faker::Commerce).to receive(:price).and_return(45)

        expect(fake_value.generate_fake_value).to eq(45.to_s)
      end
    end

    context "when column type is hstore" do
      it "returns a hash" do
        allow(column).to receive(:type).and_return(:hstore)
        allow(Faker::Lorem).to receive(:word).and_return("random_text")
        allow(Faker::Number).to receive(:number).with(digits: 2).and_return(2)

        result = { "value": { "key1": "random_text", "key2": 2 } }
        expect(fake_value.generate_fake_value.to_json).to eq(result.to_json)
      end
    end

    context "when column type is year" do
      before { srand(1) }
      after { srand }

      it "returns a year" do
        allow(column).to receive(:type).and_return(:year)

        expect(fake_value.generate_fake_value).to eq(1938)
      end
    end

    context "when column type is unknown" do
      it "raises an error" do
        allow(column).to receive(:type).and_return(:unknown)

        expect {
  fake_value.generate_fake_value
}.to raise_error(Seedie::UnknownColumnTypeError, "Unknown column type: unknown")
      end
    end
  end
end
