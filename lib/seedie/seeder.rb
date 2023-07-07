module Seedie
  class Seeder
    include Reporters::Reportable

    attr_reader :config

    def initialize(config_path = nil)
      @config_path = config_path
      @config = load_config(config_path)
      @reporters = []
      @console_reporter = Reporters::ConsoleReporter.new
      @reporters << @console_reporter
      add_observers(@reporters)
    end

    def seed_models
      report(:seed_start)
      config["models"].each do |model_name, model_config|
        model = model_name.classify.constantize
        ModelSeeder.new(model, model_config, config, @reporters).generate_records
      end
      report(:seed_finish)
      
      @reporters.each(&:close)
    end

    private

    def load_config(path)
      path = Rails.root.join("config", "seedie.yml") if path.nil?
      raise ConfigFileNotFound, "Config file not found in #{path}" unless File.exist?(path)
      
      YAML.load_file(path, aliases: true)
    end
  end
end