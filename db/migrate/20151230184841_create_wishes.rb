class CreateWishes < ActiveRecord::Migration
  def change
    create_table :wishes do |t|
      t.string :name, default: ""
      t.decimal :price, default: 0.0
      t.string :image_url, default: ""
      t.string :page_url, default: ""
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :wishes, :user_id
  end
end
