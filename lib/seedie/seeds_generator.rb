module Seedie
  class SeedsGenerator
    attr_reader :config

    def initialize(config_file)
      @config = YAML.load_file(config_file)
    end

    def perform
      config['models'].each do |model_name, model_config|
        ModelSeeds.new(model_name, model_config, config).generate_records
      end
    end
  end
end