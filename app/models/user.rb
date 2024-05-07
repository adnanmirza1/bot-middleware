class User < ApplicationRecord
  has_many :user_bots
  has_many :bots, through: :user_bots
end