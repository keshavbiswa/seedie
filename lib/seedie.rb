# frozen_string_literal: true

require "active_record"
require "faker"
require "yaml"
require "zeitwerk"

module Seedie
  @loader = Zeitwerk::Loader.for_gem
  @loader.ignore("#{__dir__}/generators")
  @loader.setup
  
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

    def eager_load!
      @loader.eager_load
    end
  end
end

Seedie.eager_load!
