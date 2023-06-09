module Seedie
  class SeedsGenerator
    attr_reader :config

    def initialize(config_path = nil)
      @config_path = config_path
      @config = load_config(config_path)
    end

    def perform
      config['models'].each do |model_name, model_config|
        ModelSeeds.new(model_name, model_config, config).generate_records
      end
    end

    private

    def load_config(path)
      path = Rails.root.join('config', 'seedie.yml') if path.nil?
      raise "Configuration file config/seedie.yml not found" unless File.exist?(path)
      
      YAML.load_file(path)
    end
  end
end