class CreateGameRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :game_rooms do |t|
      t.string :name
      t.string :token
      t.references :creator, null: false, index: true
      t.references :updater, null: false, index: true

      t.timestamps
    end
  end
end
