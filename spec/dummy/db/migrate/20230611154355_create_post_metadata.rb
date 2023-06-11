class CreatePostMetadata < ActiveRecord::Migration[7.0]
  def change
    create_table :post_metadata do |t|
      t.text :seo_text
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
