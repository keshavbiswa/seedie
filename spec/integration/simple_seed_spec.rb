require "rails_helper"

RSpec.describe "SimpleSeed" do
  let(:config_path) { "spec/fixtures/simple_config.yml" }
  let(:faker_config_path) { "spec/fixtures/simple_config_with_faker.yml" }

  it "seeds the User model based on the given config" do
    Seedie::Seeder.new(config_path).seed_models

    expect(User.count).to eq 5
    expect(User.first.name).to eq "User 0"
    expect(User.first.email).to eq "user0@example.com"
    expect(User.last.name).to eq "User 4"
    expect(User.last.email).to eq "user4@example.com"
  end

  it "seeds the User model with custom values" do
    allow(Faker::Name).to receive(:name).and_return("custom_name")
    allow(Faker::Internet).to receive(:email).and_return("custom_email")

    Seedie::Seeder.new(faker_config_path).seed_models

    expect(User.count).to eq 5
    expect(User.first.name).to eq "custom_name"
    expect(User.first.email).to eq "custom_email"
  end
end