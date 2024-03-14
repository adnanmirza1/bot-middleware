# app/controllers/telegram_bots_controller.rb
class TelegramBotsController < ApplicationController
  def get_tokens
    tokens = Telegram.all.pluck(:token)
    render json: tokens
  end
end
