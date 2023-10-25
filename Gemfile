# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in seedie.gemspec
gemspec

gem "rake", "~> 13.0"

gem "pry", "~> 0.14.2"

group :test do
  gem "simplecov", "~> 0.22.0", require: false
end

group :development, :test do
  gem "rubocop", require: false
end
