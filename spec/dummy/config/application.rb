# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.0
    config.generators.system_tests = nil
  end
end
