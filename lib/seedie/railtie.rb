# frozen_string_literal: true

require "seedie"
require "rails"

module Seedie
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/seedie.rake"
    end
  end
end
