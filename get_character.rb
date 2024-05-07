def get_character_by_id(id)
  url = URI.parse("https://ai.dev.moemate.io/api/characters/id/#{id}")
  headers = {
    'Accept' => '*/*',
    'Content-Type' => 'application/json',
    'Origin' => 'https://www.moemate.io',
    'Referer' => 'https://www.moemate.io/',
    'Authorization' => "Bearer: #{TOKEN}"
  }

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == 'https')

  request = Net::HTTP::Get.new(url.request_uri, headers)

  response = http.request(request)

  if response.code == '200'
    return JSON.parse(response.body)
  else
    puts "Error: #{response.code} - #{response.message}"
    return nil
  end
end