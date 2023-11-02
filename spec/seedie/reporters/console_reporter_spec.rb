require "rails_helper"
require "seedie"

RSpec.describe Seedie::Reporters::ConsoleReporter do
  let(:console_reporter) { described_class.new }

  before do
    allow_any_instance_of(Seedie::Reporters::ConsoleReporter).to receive(:update).and_call_original
  end

  describe "#initialize" do
    it "sets output to $stdout" do
      expect(console_reporter.output).to eq($stdout)
    end
  end

  describe "#update" do
    let(:event_type) { :model_seed_start }
    let(:body) { { name: "user" } }
    let(:message) { "Console reporting.." }

    before do
      allow(console_reporter).to receive(:messages).and_return(message)
    end

    it "adds message to reports" do
      expect { console_reporter.update(event_type, body) }.to change { console_reporter.reports.count }.by(1)
    end

    it "outputs message to stdout" do
      expect(console_reporter.output).to receive(:puts).with(message)
      console_reporter.update(event_type, body)
    end
  end
end