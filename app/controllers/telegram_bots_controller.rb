# app/controllers/telegram_bots_controller.rb
class TelegramBotsController < ApplicationController
  def get_tokens
    bots = TelegramBot.all
    render json: bots
  end

  def get_discord_tokens
    bots = DiscordBot.all
    render json: bots
  end
end
