# frozen_string_literal: true

require "seedie"

class DummyClass
  include Reporters::Reportable
end

RSpec.describe Reporters::Reportable do
  let(:dummy_class) { DummyClass.new }

  let(:observer) { Reporters::ConsoleReporter.new }
  let(:observers) { [observer] }

  describe "#report" do
    let(:event_type) { :test_event }
    let(:body) { { key: "value" } }

    before do
      dummy_class.add_observer(observer)
    end

    it "notifies observers" do
      expect(observer).to receive(:update).with(event_type, body)
      dummy_class.report(event_type, body)
    end
  end

  describe "#add_observers" do
    it "adds observers" do
      dummy_class.add_observers(observers)
      expect(dummy_class.count_observers).to eq(1)
    end
  end
end
