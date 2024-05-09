class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :telegram_userid
      t.string :username
      t.string :auth_token
      t.datetime :expire_at
      t.string :type
      t.timestamps
    end
  end
end
