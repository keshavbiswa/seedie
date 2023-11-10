# frozen_string_literal: true

require "spec_helper"
require "seedie"
require "rails_helper"

describe Seedie::Seeder do
  let(:config_path) { Rails.root.join("config", "seedie.yml") }
  let(:model_config) { { "count" => 5, "attributes" => { "name" => "name {{index}}" } } }
  let(:config) { { "models" => { "user" => model_config } } }
  let(:model_seeder) { double(:model_seeder) }

  subject { described_class.new(config_path) }

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(config)
    allow(Seedie::ModelSeeder).to receive(:new).and_return(model_seeder)
    allow(model_seeder).to receive(:generate_records)
  end

  describe "#initialize" do
    it "loads the configuration" do
      expect(subject.config).to eq(config)
    end
  end

  describe "#seed_models" do
    it "generates records for each model in the configuration" do
      subject.seed_models

      expect(model_seeder).to have_received(:generate_records)
    end
  end

  context "when configuration file does not exist" do
    it "raises an error" do
      allow(File).to receive(:exist?).and_return(false)

      expect { subject }.to raise_error(Seedie::ConfigFileNotFound, "Config file not found in #{config_path}")
    end
  end
end
