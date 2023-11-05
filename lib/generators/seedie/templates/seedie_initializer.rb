# frozen_string_literal: true

Seedie.configure do |config|
  # config.default_count = 10

  config.custom_attributes[:email] = "{{Faker::Internet.unique.email}}"
  # Add more custom attributes here
end
