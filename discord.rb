require 'discordrb'

bot = Discordrb::Bot.new token: 'MTIxNzc5NDUwMjYyNzAzMzExOA.GNPc5p.0MQhj0F03lBBk2ijO7xr74oGzVMqeoJnzXxxew'

bot.message(with_text: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.run