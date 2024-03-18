# app/controllers/telegram_bots_controller.rb
class TelegramBotsController < ApplicationController
  def get_tokens
    tokens = Telegram.all.pluck(:token)
    render json: tokens
  end

  def get_discord_tokens
    tokens = Discord.pluck(:token)
    render json: tokens
  end
end
