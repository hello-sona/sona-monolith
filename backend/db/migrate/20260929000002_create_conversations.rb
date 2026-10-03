class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false, default: "New chat"

      t.timestamps
    end

    add_index :conversations, [ :user_id, :updated_at ], order: { updated_at: :desc }
  end
end
