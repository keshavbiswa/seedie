class GameRoom < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  belongs_to :updater, class_name: "User", foreign_key: "updater_id"

  has_and_belongs_to_many :users

  validates :name, presence: true
end
