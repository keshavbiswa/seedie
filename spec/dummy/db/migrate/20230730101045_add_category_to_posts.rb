class AddCategoryToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :category, :string
  end
end
