require 'spec_helper'
require "seedie"

describe Seedie::SeedsGenerator do
  let(:config_path) { Rails.root.join('config', 'seedie.yml') }
  let(:model_config) { {} }
  let(:config) { {'models' => {'User' => model_config}} }
  let(:model_seeds) { double(:model_seeds) }
  
  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(YAML).to receive(:load_file).and_return(config)
    allow(Seedie::ModelSeeds).to receive(:new).and_return(model_seeds)
    allow(model_seeds).to receive(:generate_records)
  end
  
  describe '#initialize' do
    it 'loads the configuration' do
      seeds_generator = described_class.new(config_path)
      expect(seeds_generator.config).to eq(config)
    end
  end

  describe '#perform' do
    it 'generates records for each model in the configuration' do
      seeds_generator = described_class.new(config_path)
      seeds_generator.perform
      expect(Seedie::ModelSeeds).to have_received(:new).with('User', model_config, config)
      expect(model_seeds).to have_received(:generate_records)
    end
  end

  context 'when configuration file does not exist' do
    it 'raises an error' do
      allow(File).to receive(:exist?).and_return(false)
      expect { described_class.new(config_path) }.to raise_error("Configuration file config/seedie.yml not found")
    end
  end
end
