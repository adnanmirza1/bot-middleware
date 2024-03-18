require 'net/http'
require 'json'

class TextGenerationService
  API_URL = 'http://alb-beta.dev.moemate.io/generate'.freeze

  def self.generate_text(inputs)
    uri = URI(API_URL)
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
      JSON.parse(response.body)
    else
      nil # or handle error as needed
    end
  end
end
