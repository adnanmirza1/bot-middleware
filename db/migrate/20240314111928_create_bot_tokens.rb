class CreateBotTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :bot_tokens do |t|
      t.string :token
      t.string :user_name
      t.string :type
      t.timestamps
    end
  end
end
