require "rails_helper"

RSpec.describe "PolymorphicAssociation" do
  let(:config_path) { "spec/fixtures/polymorphic_association_config.yml" }

  describe "seeding the Review Model" do
    before do
      Seedie::Seeder.new(config_path).seed_models
    end

    it "seeds the Review model based on the given config" do
      expect(Review.count).to eq 5
      expect(Review.first.content).to eq "Review 0"
      expect(Review.pluck(:user_id) - User.ids).to be_empty
    end

    it "assigns polymorphic associations for Reviewable" do
      expect(Review.first.reviewable_type).to be_in(["Post", "GameRoom"])
      expect(Review.pluck(:reviewable_id) - Post.ids - GameRoom.ids).to be_empty
    end
  end
end