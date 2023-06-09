require 'spec_helper'
require "seedie"

describe Seedie::FieldValuesGenerator do
  let(:column_hash) { [{ id: double(:column) }, { name: double(:column) }, { created_at: double(:column) }, { updated_at: double(:column) }] }
  let(:model) { double(:model) }
  let(:model_config) { {} }
  let(:index) { 1 }
  let(:field_values_generator) { described_class.new(model, model_config, index) }

  describe '#generate_field_values' do
    before do
      allow(model).to receive(:column_names).and_return(column_hash)
    end
    
    it 'returns a hash of field values' do
      allow(model).to receive(:columns_hash).and_return({})
      expect(field_values_generator.generate_field_values).to eq({})
    end
  end
end