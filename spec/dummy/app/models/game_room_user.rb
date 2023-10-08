class GameRoomUser < ApplicationRecord
  belongs_to :game_room
  belongs_to :user

  validates :user_id, uniqueness: { scope: :game_room_id, message: "should be unique" }
end
