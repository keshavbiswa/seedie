# frozen_string_literal: true

class AddStatusToSimpleModel < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_models, :status, :integer, default: 0
  end
end
