# frozen_string_literal: true

require_relative "seedie/fake_value_generator"
require_relative "seedie/custom_field_value_generator"
require_relative "seedie/field_values_generator"
require_relative "seedie/model_fields"
require_relative "seedie/model_loader"
require_relative "seedie/seeder"
require_relative "seedie/version"

require 'seedie/railtie' if defined?(Rails)

require "active_record"
require "faker"
require "yaml"

module Seedie
  class Error < StandardError; end
  # Your code goes here...
end
