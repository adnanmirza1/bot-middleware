class TelegramBotService
	require 'telegram/bot'

  def self.webhook
    token = '7003487106:AAGnw_CmEaVmaLvyyOUgl6KSJPu0vRppGP0'
    bot = Telegram::Bot::Client.new(token)
    byebug
		bot.listen do |message|
			case message.text
			when '/start'
				bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
			when '/stop'
				bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
			end
		end

  end
end