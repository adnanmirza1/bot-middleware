def get_embedding(input_text)
    url = URI.parse('https://ai.moemate.io/api/ai/embeddings')
    headers = {
      'Accept' => '*/*',
      'Content-Type' => 'application/json',
      'Origin' => 'https://www.moemate.io',
      'Referer' => 'https://www.moemate.io/',
      'Webaauth' => TOKEN
    }
    body = {
      input: [input_text],
      model: 'text-embedding-ada-002'
    }.to_json
  
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
  
    request = Net::HTTP::Post.new(url.request_uri, headers)
    request.body = body
  
    response = http.request(request)
    puts response
    return response.body
  end
  
  def classify_text(input_text)
    labels = ["send a selfie", "take or share a photo of self", "draw a self portrait", "create, generate, or share a new piece of artwork", "asking to search for the weather", "search the web for information", "search for news articles", "describing a story in depth", "fashion designer"]
    url = URI.parse('https://ai.moemate.io/api/classification')
    headers = {
      'Accept' => '*/*',
      'Content-Type' => 'application/json',
      'Origin' => 'https://www.moemate.io',
      'Referer' => 'https://www.moemate.io/',
      'Webahost' => 'classification.dev.moemate.io',
      'Webaauth' => TOKEN
    }
    body = {
      text: input_text,
      labels: labels
    }.to_json
  
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
  
    request = Net::HTTP::Post.new(url.request_uri, headers)
    request.body = body
  
    response = http.request(request)
    return response.body
  end
  