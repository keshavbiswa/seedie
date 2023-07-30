class CreateSimpleModels < ActiveRecord::Migration[7.0]
  def change
    create_table :simple_models do |t|
      t.string :name
      t.text :content
      t.string :category

      t.timestamps
    end
  end
end
