require 'spec_helper'
require "rails"

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)

require 'rspec/rails'

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Migration.check_pending!
    ActiveRecord::Migration.maintain_test_schema!
  end

  config.use_transactional_fixtures = true
end
