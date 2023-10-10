# frozen_string_literal: true

class GameRoom < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "user_id"
  belongs_to :updater, class_name: "User", foreign_key: "updater_id"

  has_many :reviews, as: :reviewable
  has_many :game_room_users, dependent: :destroy
  has_many :users, through: :game_room_users

  validates :name, presence: true
end
