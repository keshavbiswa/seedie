require 'spec_helper'
require "seedie"

describe Seedie::ModelLoader do
  let(:model_name) { 'User' }
  let(:model_config) { {} }
  let(:config) { {} }
  let(:model_class) { double(:model_class) }
  let(:field_values_generator) { double(:field_values_generator, generate_field_values: {}) }

  before do
    stub_const("#{model_name}", model_class)
    allow(Seedie::FieldValuesGenerator).to receive(:new).and_return(field_values_generator)
    allow(model_class).to receive(:create!)
  end
  
  describe '#generate_records' do
    context 'when count is specified in model_config' do
      let(:model_config) { {'count' => 2} }

      it 'generates the specified number of records' do
        described_class.new(model_name, model_config, config).generate_records
        expect(model_class).to have_received(:create!).twice
      end
    end

    context 'when default_count is specified in config' do
      let(:config) { {'default_count' => 3} }

      it 'generates the default number of records' do
        described_class.new(model_name, model_config, config).generate_records
        expect(model_class).to have_received(:create!).exactly(3).times
      end
    end

    context 'when count is not specified' do
      it 'generates one record' do
        described_class.new(model_name, model_config, config).generate_records
        expect(model_class).to have_received(:create!).once
      end
    end
  end
end
