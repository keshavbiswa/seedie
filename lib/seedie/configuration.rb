# frozen_string_literal: true

module Seedie
  class Configuration
    attr_accessor :default_count, :custom_attributes

    def initialize
      @default_count = nil
      @custom_attributes = {}
    end
  end
end
