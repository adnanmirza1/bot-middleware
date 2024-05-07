class UserBot < ApplicationRecord
  belongs_to :bot
  belongs_to :user

  enum user_type: { user: 0, bot: 1 }
end