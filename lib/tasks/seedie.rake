# frozen_string_literal: true

require "seedie"

namespace :seedie do
  desc "Load the Seedie seeds"
  task seed: :environment do
    Seedie::Seeder.new.seed_models
  end
end
