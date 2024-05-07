def generated_text(prompt, character_id)
  url = URI.parse('https://generation.moemate.io/api/generation/PAPERSPACE_COMPLETION/stream')
  headers = {
    'Accept' => '*/*',
    'Content-Type' => 'application/json',
    'Model-Id' => 'llm7',
    'Origin' => 'https://www.moemate.io',
    'Referer' => 'https://www.moemate.io/',
    'Webaauth' => TOKEN,
    'Webachar' => character_id
  }
  body = {
    model: 'llm7',
    inputs: "Below is an instruction that describes a task. Write a response that appropriately completes the request. ### Instruction: #{prompt}",
    parameters: {
      best_of: 1,
      decoder_input_details: true,
      details: false,
      stream: false,
      do_sample: true,
      max_new_tokens: 350,
      repetition_penalty: 1,
      return_full_text: false,
      seed: nil,
      stop: [ "USER:", "User:", "Human: ", "Adnan1:" ],
      temperature: 0.7,
      top_k: 20,
      top_p: 0.9,
      truncate: nil,
      typical_p: 0.99,
      watermark: false
    }
  }

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(url, headers)
  request.body = body.to_json

  response = http.request(request)
 
  if response.code == '200'
    return JSON.parse(response.body)["generated_text"]
  else
    raise "Failed to make chat API request. Response code: #{response.code}"
  end
end