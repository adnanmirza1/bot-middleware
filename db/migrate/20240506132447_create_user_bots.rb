class CreateUserBots < ActiveRecord::Migration[7.0]
  def change
    create_table :user_bots do |t|
      t.references :bot
      t.references :user
      t.string :message
      t.integer :user_type
      t.timestamps
    end
  end
end
