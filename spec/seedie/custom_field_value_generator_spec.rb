require 'spec_helper'
require "seedie"

describe Seedie::CustomFieldValueGenerator do
  let(:name) { 'name' }
  let(:value_template) { "value_template{{index}}" }
  let(:index) { 1 }
  let(:custom_field_value_generator) { described_class.new(name, value_template, index) }

  describe '#generate_custom_field_value' do
    it 'returns the value_template with index interpolated' do
      expect(custom_field_value_generator.generate_custom_field_value).to eq("value_template1")
    end
  end
end