module Seedie
  class Seeder
  attr_reader :config
  
  def initialize(config_path = nil)
      @config_path = config_path
      @config = load_config(config_path)
    end

    def seed_models
      config['models'].each do |model_name, model_config|
        model = model_name.classify.constantize
        ModelLoader.new(model, model_config, config).generate_records
      end
    end

    private

    def load_config(path)
      path = Rails.root.join('config', 'seedie.yml') if path.nil?
      raise ConfigFileNotFound, "Config file not found in #{path}" unless File.exist?(path)
      
      YAML.load_file(path)
    end
  end
end