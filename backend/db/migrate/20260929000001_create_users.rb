class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :display_name, null: false, default: ""
      t.string :google_sub
      t.string :password_digest
      t.boolean :admin, null: false, default: false
      t.boolean :active, null: false, default: true
      t.datetime :last_login_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :google_sub, unique: true
  end
end
