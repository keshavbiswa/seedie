require "rails/generators"
require "generators/seedie/install_generator"
require "fileutils"
require "generator_spec"
require "rails_helper"
require "seedie"

RSpec.describe Seedie::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)
  let(:seedie_config) { File.join(destination_root, "config", "seedie.yml") }
  let(:content) { YAML.load_file(seedie_config) }

  before do
    Rails.application.eager_load!
    prepare_destination
    run_generator
  end


  after do
    FileUtils.rm_rf destination_root
  end

  it "creates a config file" do
    expect(File).to exist(seedie_config)
  end

  describe "#model_configuration" do

    it "excludes reserved models" do
      excluded_models = described_class::EXCLUDED_MODELS.map(&:underscore)
      expect(content["models"]).not_to include(*excluded_models)
    end

    it "excludes abstract models" do
      expect(content["models"]).not_to include("application_record")
    end

    it "excludes models without tables" do
      expect(content["models"]).not_to include("model_without_table")
    end

    it "excludes HABTM models" do
      expect(content["models"]).not_to include("habtm_game_rooms", "habtm_users")
    end

    it "generates required models" do
      expect(content["models"]).to include("user", "post", "comment", "game_room")
    end

    it "sorts models by dependency" do
      expect(content["models"].keys).to eq ["user", "simple_model", "post", "review", "post_metadatum", "game_room", "comment"]
    end

    it "generates model_configuration for each model" do
      expect(content["models"].each { |model, config| expect(config).to include("attributes", "associations") })
    end
  end

  describe "#active_columns_configuration" do
    it "generates required attributes" do
      expect(content["models"]["simple_model"]["attributes"]).to include("category")
      expect(content["models"]["user"]["attributes"]).to include("name", "email", "password")
      expect(content["models"]["post"]["attributes"]).to include("category")
      expect(content["models"]["comment"]["attributes"]).to include("content")
      expect(content["models"]["game_room"]["attributes"]).to include("name")
    end

    it "excludes foreign_keys" do
      expect(content["models"]["user"]["attributes"]).not_to include("game_room_id")
      expect(content["models"]["game_room"]["attributes"]).not_to include("creator_id", "updater_id")
    end

    it "excludes polymorphic_types" do
      expect(content["models"]["review"]["attributes"]).not_to include("reviewable_type")
    end

    it "includes other columns with _type" do
      expect(content["models"]["review"]["disabled_fields"]).to include("review_type")
    end

    it "generates required belongs_to associations" do
      expect(content["models"]["comment"]["associations"]["belongs_to"]).to include("post")
    end
  end

  describe "#disabled_columns_configuration" do
    it "adds disabled_columns to the disabled_fields" do
      expect(content["models"]["user"]["disabled_fields"]).to include("nickname", "address")
      expect(content["models"]["simple_model"]["disabled_fields"]).to include("name", "content")
      expect(content["models"]["post"]["disabled_fields"]).to include("title", "content")
      expect(content["models"]["game_room"]["disabled_fields"]).to include("token")
    end

    it "adds default columns to the disabled_fields" do
      expect(content["models"]["simple_model"]["disabled_fields"]).to include("status")
    end
  end

  describe "#belongs_to_associations_configuration" do
    it "excludes optional associations" do
      expect(content["models"]["comment"]["associations"]["belongs_to"]).not_to include("user")
    end

    it "generates required belongs_to associations" do
      expect(content["models"]["user"]["associations"]["belongs_to"]).to be nil
      expect(content["models"]["post"]["associations"]["belongs_to"]).to be nil
      expect(content["models"]["post_metadatum"]["associations"]["belongs_to"]).to include("post")
      expect(content["models"]["game_room"]["associations"]["belongs_to"]).to include("creator", "updater")
      expect(content["models"]["comment"]["associations"]["belongs_to"]).to include("post")
    end

    it "generates required polymorphic belongs_to associations" do
      expect(content["models"]["review"]["associations"]["belongs_to"]).to include("reviewable")
      expect(content["models"]["review"]["associations"]["belongs_to"]["reviewable"]).to include("polymorphic")
    end
  end

  describe "Validations" do
    it "ensures unique columns have unique values" do
      expect(content["models"]["user"]["attributes"]["email"]).to eq("{{Faker::Lorem.unique.word}}")
    end

    it "generates random attributes from a given values array" do
      category_values = {"values"=>["tech", "news", "sports", "politics", "entertainment"], "options"=> { "pick_strategy" => "random" }}
      
      expect(content["models"]["simple_model"]["attributes"]["category"]).to eq(category_values)
    end

    it "generates ranges for inclusion with ranges" do
      expect(content["models"]["simple_model"]["attributes"]["score"]).to eq({"values"=>{ "start" => 0, "end" => 10}, "options"=>{"pick_strategy"=>"random"}})
    end
  end
end
