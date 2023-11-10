# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CustomAttributes" do
  let(:category_array) { %w[tech news sports politics entertainment] }
  describe "RandomAttributes" do
    let(:config_path) { "spec/fixtures/random_attributes_config.yml" }

    before do
      Seedie::Seeder.new(config_path).seed_models
    end

    it "seeds the Post model based on the given config" do
      expect(Post.count).to eq 5
    end

    it "assigns category a random value from the given array" do
      expect(Post.first.category).to be_in(category_array)
    end
  end

  describe "SequentialAttributes" do
    let(:config_path) { "spec/fixtures/sequential_attributes_config.yml" }

    before do
      Seedie::Seeder.new(config_path).seed_models
    end

    it "assigns category a sequential value from the given array" do
      expect(Post.first.category).to eq category_array[0]
      expect(Post.second.category).to eq category_array[1]
      expect(Post.third.category).to eq category_array[2]
    end
  end
end
