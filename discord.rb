require 'discordrb'
require 'json'
require 'net/http'

bot = Discordrb::Bot.new token: 'MTIxODE2MDUwMzkyMzQxMzA3Mg.GYm2ta.biXgfnL0OW9ksQhY0EDVovieuI0_lXkOwFEFsE'
GENERATE_TEXT_API_URL = 'http://alb-beta.dev.moemate.io/generate'

bot.message do |event|
  if event.message.content
    inputs = event.message.content.to_s
    
    uri = URI(GENERATE_TEXT_API_URL)
    headers = {
      'Host': 'llm7',
      'Content-Type': 'application/json'
    }

    data = {
      inputs: inputs,
      parameters: {
        best_of: 1,
        decoder_input_details: true,
        details: false,
        stream: true,
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
      generated_text = response_data['generated_text']
      event.respond "Generated text: #{generated_text}"
    else
      event.respond "Failed to generate text. Error: #{response.body}"
    end
  end
end

bot.run
