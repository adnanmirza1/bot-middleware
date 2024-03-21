require 'telegram/bot'
require 'json'
require 'net/http'

GENERATE_TEXT_API_URL = 'http://alb-beta.dev.moemate.io/generate'
TELEGRAM_TOKENS_URL = 'http://localhost:3000/get_tokens'

def get_telegram_tokens
  url = URI.parse(TELEGRAM_TOKENS_URL)
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
      best_of: 1, decoder_input_details: true,  details: false, stream: false,
      do_sample: true, max_new_tokens: 500,
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

tokens = get_telegram_tokens

tokens.each do |token|
  Thread.new do
    Telegram::Bot::Client.run(token) do |bot|
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::Message
          if message.audio
            # Handle audio message
          elsif message.photo
            # Handle photo message
          else
            inputs = message.text
            generated_text = generate_text(inputs)
            bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{generated_text}")
          end
        end
      end
    end
  end
end

# Sleep to keep the main thread alive
sleep
