class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :link
      t.text :message
      t.integer :time
      t.boolean :publish
      t.string :post_id
      t.string :page_id

      t.timestamps null: false
    end
  end
end
