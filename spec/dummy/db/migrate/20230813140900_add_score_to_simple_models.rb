# frozen_string_literal: true

class AddScoreToSimpleModels < ActiveRecord::Migration[7.0]
  def change
    add_column :simple_models, :score, :integer
  end
end
