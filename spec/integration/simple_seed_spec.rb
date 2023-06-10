require 'rails_helper'

RSpec.describe "SimpleSeed" do
  before do
    @config_path = "spec/fixtures/simple_config.yml"
  end

  it 'seeds the User model based on the given config' do
    Seedie::Seeder.new(@config_path).seed_models

    expect(User.count).to eq 5
    expect(User.first.name).to eq 'User 0'
    expect(User.first.email).to eq 'user0@example.com'
    expect(User.last.name).to eq 'User 4'
    expect(User.last.email).to eq 'user4@example.com'
  end
end