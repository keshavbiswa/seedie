# frozen_string_literal: true

class AddBoardsUsersJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :boards, :users do |t|
      t.index :board_id
      t.index :user_id
    end
  end
end
