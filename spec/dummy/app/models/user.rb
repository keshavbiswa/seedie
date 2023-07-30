class User < ApplicationRecord
  has_many :posts
  has_many :reviews
  
  has_and_belongs_to_many :game_rooms

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true
  validates :password, presence: true
end
