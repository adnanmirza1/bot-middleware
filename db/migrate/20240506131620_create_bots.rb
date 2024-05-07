class CreateBots < ActiveRecord::Migration[7.0]
  def change
    create_table :bots do |t|
      t.string :token
      t.string :bot_user_name
      t.string :character_name
      t.string :characterid
      t.string :type
      t.timestamps
    end
  end
end
