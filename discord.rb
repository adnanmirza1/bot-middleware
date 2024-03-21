require 'discordrb'
require 'json'
require 'net/http'

GENERATE_TEXT_API_URL = 'http://alb-beta.dev.moemate.io/generate'
DISCORD_TOKENS_URL = 'http://localhost:3000/get_discord_tokens'

def get_discord_tokens
  url = URI.parse(DISCORD_TOKENS_URL)
  response = Net::HTTP.get_response(url)

  if response.is_a?(Net::HTTPSuccess)
    return JSON.parse(response.body)
  else
    puts "Failed to get tokens. Response code: #{response.code}"
    return []
  end
end

def generate_text(inputs)
  uri = URI(GENERATE_TEXT_API_URL)
  headers = {
      'model_id': 'llm7',
      'Content-Type': 'application/json'
    }

  data = {
    inputs: inputs,
    parameters: {
      best_of: 1,
      decoder_input_details: true,
      details: false,
      stream: false,
      do_sample: true,
      max_new_tokens: 500,
      repetition_penalty: 1.15,
      return_full_text: false,
      seed: nil,
      stop: [],
      temperature: 0.9,
      top_k: 10,
      top_p: 0.6,
      truncate: nil,
      typical_p: 0.99,
      watermark: false
    }
  }

  response = Net::HTTP.post(uri, data.to_json, headers)
  
  if response.code == '200'
    response_data = JSON.parse(response.body)
    return response_data['generated_text']
  else
    puts "Failed to generate text. Error: #{response.body}"
    return nil
  end
end

tokens = get_discord_tokens
bots = []

tokens.each do |token|
  bot = Discordrb::Bot.new token: token
  bots.push(bot)
end

bots.each do |bot|
  bot.message do |event|
    if event.message.content
      inputs = event.message.content.to_s
      generated_text = generate_text(inputs)
      
      if generated_text
        event.respond "#{generated_text}"
      else
        event.respond "Failed to generate text."
      end
    end
  end
  
  bot.run  
end