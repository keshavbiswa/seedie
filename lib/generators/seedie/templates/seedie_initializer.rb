# frozen_string_literal: true

Seedie.configure do |config|
  # config.default_count = 10

  config.custom_attributes[:email] = "{{Faker::Internet.unique.email}}"
  # Model-Specific Custom Attributes
  #
  # Use the prepare_custom_attributes_for method to initialize the custom_attributes hash
  # for the specified models. This ensures that you can safely set model-specific custom
  # attributes without encountering NoMethodError.
  #
  # Example:
  # config.prepare_custom_attributes_for :user, :account
  #
  # Now you can set custom attributes for these models:
  # config.custom_attributes[:user][:email] = "user@example.com"
  # config.custom_attributes[:account][:name] = "{{Faker::Business.name}}"
  #
  # Add more custom attributes here
  #
end
