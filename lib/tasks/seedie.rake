require "seedie"

namespace :seedie do
  desc "Load the Seedie seeds"
  task :seed => :environment do
    Seedie::SeedsGenerator.new.perform
  end
end