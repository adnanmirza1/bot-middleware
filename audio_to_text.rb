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
    webaauth: "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlMzLUstVWhieEtHYnExbF8tbEloMiJ9.eyJhcHBfbWV0YWRhdGEiOnsic3RyaXBlX2N1c3RvbWVyX2lkIjoiY3VzX1BsdEFmTEdmZHFDU1BiIiwic3ViX3N0YXR1cyI6InBybyIsInVzZXJuYW1lIjoiVGVzdCBEZXYifSwibmlja25hbWUiOiJ0ZXN0ZGV2MCIsIm5hbWUiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvOTViMTljNWI1ODBhOTVjNjk5YTQ2ODg3OWE4MmUwYTQ_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ0ZS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyNC0wMy0yMFQxODoxNjo0MS42ODZaIiwiZW1haWwiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlzcyI6Imh0dHBzOi8vbW9lbWF0ZS1kZXYudXMuYXV0aDAuY29tLyIsImF1ZCI6IlIzOTBCNFNMdnA2OTRTWmN4T2NEYk1Pd3NFdDd0ZWJBIiwiaWF0IjoxNzEwOTk3Nzc2LCJleHAiOjE3MTEwMzM3NzYsInN1YiI6ImF1dGgwfDY1Zjg3N2I5NWMyY2QxNGNmYmQzMDU1NyIsInNpZCI6Ii1SSW5aUnBUdlpuTWhaTk0zQlpaRG8zRjNCTGY2UTh6In0.SIjqQLKPmQt-BIzm3u2D-UWO9WVALOaV2Sl8mbmUHDxmnLRiN0e2FM62RJJb3CIgdjxDKXnSYOmchAvyujETbsd9-mNVdAjj3kZTnRfunPjdwN1zzdBBpG17mAfqHKEDeHSDxM5VIo2SP5dhP7qzbRDpyf-1vUs3lPNX8Qv7OXeeTrNsBJ9dmwRvqdLY9cNzZYfy0Y6y7iIs6re3_6axBWTSRv-VqvlbisQCHG2lXRNTiO0ozm8ehsYJX1mwyrksn2_5WbP92AB_PeAtpA2JePpNFBKmpyPXxEKN4mvspGQGtXQNzzpFXwcn3VAi1g_Tj0ndVvAGJJQ2QNi-jUrizg"
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
