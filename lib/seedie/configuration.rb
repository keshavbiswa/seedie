# frozen_string_literal: true

module Seedie
  class Configuration
    attr_accessor :default_count, :custom_attributes

    def initialize
      @default_count = nil
      @custom_attributes = {}
    end

    # Prepares the custom_attributes hash for the specified models.
    #
    # This method ensures that the necessary keys exist in the custom_attributes hash.
    # This prevents NoMethodError when setting model-specific custom attributes.
    #
    # Example usage:
    # config.prepare_custom_attributes_for :user, :account
    #
    # Then this will work:
    # config.custom_attributes[:user][:name] = "Name"
    # config.custom_attributes[:account][:email] = "email@example.com"
    #
    def prepare_custom_attributes_for(*models)
      models.inject(@custom_attributes) do |hash, key|
        hash[key] ||= {}
      end
    end
  end
end
