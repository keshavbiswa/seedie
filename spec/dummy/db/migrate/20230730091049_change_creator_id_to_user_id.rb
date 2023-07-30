class ChangeCreatorIdToUserId < ActiveRecord::Migration[7.0]
  def change
    rename_column :game_rooms, :creator_id, :user_id
  end
end
