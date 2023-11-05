require "rails_helper"

RSpec.describe "JoinTablesSeed" do
  let(:config_path) { "spec/fixtures/join_table_config.yml" }

  describe "seeding the User Model" do
    before do
      Seedie::Seeder.new(config_path).seed_models
    end

    it "seeds the User model based on the given config" do
      expect(User.count).to eq 5
      expect(User.first.name).to eq "name 0"
    end

    it "Creates Has many association for Review" do
      expect(Review.first.reviewable_type).to eq("SimpleModel")
      expect(Review.first.user_id).to be_in(User.ids)
    end
  end
end
