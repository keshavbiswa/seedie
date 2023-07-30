require "rails_helper"

RSpec.describe "ComplexSeed" do
  let(:config_path) { "spec/fixtures/complex_config.yml" }

  describe "seeding the User model" do
    before do
      allow(Faker::Address).to receive(:street_address).and_return("custom_address")
      Seedie::Seeder.new(config_path).seed_models
    end

    it "seeds the User model based on the given config" do
      expect(User.count).to eq 5
      expect(User.first.name).to eq "name 0"
      expect(User.first.address).to eq "custom_address"
      expect(User.first.valid?).to eq true
    end
  end

  describe "seeding the Post model" do
    before do
      allow(Faker::Lorem).to receive(:paragraph).and_return("custom_content")
      Seedie::Seeder.new(config_path).seed_models
    end

    it "seeds the Post model based on the given config" do
      # Post where title begins with title
      post = Post.where("title LIKE ?", "title%")
      expect(post.count).to eq 2
      expect(post.first.title).to eq "title 0"
    end

    it "creates the specified number of comments for each post" do
      expect(Post.first.comments.count).to eq 4
    end

    it "adds category to each post randomly" do
      expect(Post.first.category).to be_in(["tech", "news", "sports", "politics", "entertainment"])
    end

    it "sets the user association from existing users" do
      expect(Post.first.user_id).to be_in(User.ids)
    end

    it "creates post_metadatum for each post" do
      expect(PostMetadatum.count).to eq 2

      expect(PostMetadatum.first.seo_text).to eq "custom_content"
    end
  end

  describe "seeding the Comment model" do
    before do
      Seedie::Seeder.new(config_path).seed_models
    end

    it "seeds the Comment model based on the given config" do
      expect(Comment.count).to eq 13
    end

    it "creates a new post with a new title" do
      expect(Comment.last.post.title).to eq "Comment Post 0"
    end
  end

  describe "seeding the GameRoom model" do
    before do
      allow(Faker::Game).to receive(:title).and_return("custom_title")
      Seedie::Seeder.new(config_path).seed_models
    end

    it "seeds the GameRoom model based on the given config" do
      expect(GameRoom.count).to eq 5
      expect(GameRoom.first.name).to eq "custom_title"
      expect(GameRoom.first.user_id).to be_in(User.ids)
      expect(GameRoom.first.updater_id).to be_in(User.ids)
    end
  end
end