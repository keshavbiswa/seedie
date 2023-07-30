require "rails_helper"

RSpec.describe "ForeignKey" do
  let(:config_path) { "spec/fixtures/foreign_key_config.yml" }

  describe "seeding the Game Model" do
    before do
      Seedie::Seeder.new(config_path).seed_models
    end

    it "seeds the GameRoom model based on the given config" do
      expect(GameRoom.count).to eq 5
      expect(GameRoom.first.name).to eq "Game Room 0"
      expect(GameRoom.first.updater_id).to be_in(User.ids)
    end

    it "assigns correct foreign key even if the association name is different" do
      expect(GameRoom.first.user_id).to be_in(User.ids)
      expect(GameRoom.first.creator).to be_in(User.all)
    end
  end
end