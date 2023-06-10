require 'spec_helper'
require "seedie"

describe Seedie::Seeder do
  let(:config_path) { Rails.root.join('config', 'seedie.yml') }
  let(:model_config) { {} }
  let(:config) { {'models' => {'User' => model_config}} }
  let(:model_loader) { double(:model_loader) }
  
  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(config)
    allow(Seedie::ModelLoader).to receive(:new).and_return(model_loader)
    allow(model_loader).to receive(:generate_records)
  end
  
  describe '#initialize' do
    it 'loads the configuration' do
      seeder = described_class.new(config_path)
      expect(seeder.config).to eq(config)
    end
  end

  describe '#seed_models' do
    it 'generates records for each model in the configuration' do
      seeder = described_class.new(config_path)
      seeder.seed_models
      expect(Seedie::ModelLoader).to have_received(:new).with('User', model_config, config)
      expect(model_loader).to have_received(:generate_records)
    end
  end

  context 'when configuration file does not exist' do
    it 'raises an error' do
      allow(File).to receive(:exist?).and_return(false)
      expect { described_class.new(config_path) }.to raise_error("Configuration file config/seedie.yml not found")
    end
  end
end
