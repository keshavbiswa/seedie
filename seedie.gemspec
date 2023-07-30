# frozen_string_literal: true

require_relative "lib/seedie/version"

Gem::Specification.new do |spec|
  spec.name = "seedie"
  spec.version = Seedie::VERSION
  spec.authors = ["Keshav Biswa"]
  spec.email = ["keshavbiswa21@gmail.com"]

  spec.summary = "Automate Database Seeding For ActiveRecord"
  spec.description = <<-DESC
    A Rails gem to automate and customize database seeding for ActiveRecord models, using Faker and configurable YAML files.
  DESC

  spec.homepage = "https://github.com/keshavbiswa/seedie"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.7"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faker", "~> 2.9"
  spec.add_dependency "activerecord", ">= 5.2.0"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "generator_spec"
  spec.add_development_dependency "rails"

  spec.add_development_dependency "sqlite3", "~> 1.4"
end
