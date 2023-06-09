# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"


desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = %w[-w]
  t.rspec_opts = %w[--color]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]
