require 'rails/generators'
require 'generators/seedie/install_generator'
require 'fileutils'
require "generator_spec"
require "rails_helper"

RSpec.describe Seedie::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)

  before do
    Rails.application.eager_load!
    prepare_destination
  end

  after do
    FileUtils.rm_rf destination_root
  end

  context "when a seedie.yml file doesn't exist" do
    it 'creates a config file' do
      run_generator
      expect(destination_root).to have_structure {
        directory 'config' do
          file 'seedie.yml' do
            contains 'default_count: 5'
            contains 'models:'
            contains 'user:' do
              contains 'count: 10'
              contains 'attributes:' do
                contains 'name: name {{index}}'
                contains 'email: email {{index}}'
              end
              contains 'disabled_fields: []'
            end
            contains 'post:' do
              contains 'count: 10'
              contains 'attributes:' do
                contains 'title: title {{index}}'
              end
              contains 'disabled_fields: []'
            end
          end
        end
      }
    end
  end
end
