require 'net/http'
require 'uri'

def upload_audio_file(file_path)
  url = URI.parse("https://ai.dev.moemate.io/api/ai/audio/transcriptions")
  headers = {
    accept: "*/*",
    model_id: "llm6",
    "accept-language": "en-US,en;q=0.9,ru;q=0.8",
    dnt: "1",
    origin: "https://dev.moemate.io",
    referer: "https://dev.moemate.io/",
    "sec-ch-ua": '"Chromium";v="122", "Not(A:Brand";v="24", "Google Chrome";v="122"',
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": '"macOS"',
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "same-site",
    "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    webaauth: "Bearer #{TOKEN}"
  }

  request = Net::HTTP::Post.new(url)
  request['Content-Type'] = 'audio/webm'
  request['model_id'] = 'llm6'
  request['accept-language'] = 'en-US,en;q=0.9,ru;q=0.8'
  request['webaauth'] = headers[:webaauth]

  form_data = [['file', File.open(file_path)]]
  request.set_form form_data, 'multipart/form-data'

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  response = http.request(request)

  if response.code == '200'
    response_body = JSON.parse(response.body)
    response_body['text']
  else
    nil
  end
end
