# frozen_string_literal: true

require_relative "seedie/reporters/reportable"
require_relative "seedie/reporters/base_reporter"
require_relative "seedie/reporters/console_reporter"

require_relative "seedie/field_values/fake_value"
require_relative "seedie/field_values/custom_value"
require_relative "seedie/field_values/faker_builder"
require_relative "seedie/field_values_set"
require_relative "seedie/model_fields"
require_relative "seedie/model_seeder"

require_relative "seedie/polymorphic_association_helper"

require_relative "seedie/model/creator"
require_relative "seedie/model/model_sorter"
require_relative "seedie/model/id_generator"

require_relative "seedie/associations/base_association"
require_relative "seedie/associations/has_many"
require_relative "seedie/associations/has_one"
require_relative "seedie/associations/belongs_to"

require_relative "seedie/seeder"
require_relative "seedie/version"
require_relative "seedie/configuration"

require "seedie/railtie" if defined?(Rails)

require "active_record"
require "faker"
require "yaml"

module Seedie
  class Error < StandardError; end
  class InvalidFakerMethodError < StandardError; end
  class UnknownColumnTypeError < StandardError; end
  class ConfigFileNotFound < StandardError; end
  class InvalidAssociationConfigError < StandardError; end
  class InvalidCustomFieldKeysError < StandardError; end
  class InvalidCustomFieldValuesError < StandardError; end
  class InvalidCustomFieldOptionsError < StandardError; end
  class CustomFieldNotEnoughValuesError < StandardError; end

  class << self
    def configure
      yield configuration if block_given?
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
