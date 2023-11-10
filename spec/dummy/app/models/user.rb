# frozen_string_literal: true

class User < ApplicationRecord
  has_many :posts
  has_many :reviews

  has_many :game_room_users, dependent: :destroy
  has_many :game_rooms, through: :game_room_users

  has_and_belongs_to_many :boards

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true
  validates :password, presence: true
end
