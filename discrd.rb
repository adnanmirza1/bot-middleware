require './image_to_text'
# require './generate_text.rb'
require 'discordrb'
require 'mini_magick'
require 'net/http'
require 'json'

bot = Discordrb::Bot.new token: ''



GENERATE_TEXT_API_URL = 'https://ai.dev.moemate.io/api/chat'.freeze

def generate_text(inputs)
  uri = URI.parse(GENERATE_TEXT_API_URL)
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
      stop: ["USER:", "User:", "Human:"],
      temperature: 0.9,
      top_k: 10,
      top_p: 0.6,
      truncate: nil,
      typical_p: 0.99,
      watermark: false
    }
  }

  headers = {
    'Content-Type': 'application/json',
    'webahost': 'llm2.dev.moemate.io',
    'WebaAuth': "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlMzLUstVWhieEtHYnExbF8tbEloMiJ9.eyJhcHBfbWV0YWRhdGEiOnsic3RyaXBlX2N1c3RvbWVyX2lkIjoiY3VzX1BsdEFmTEdmZHFDU1BiIiwic3ViX3N0YXR1cyI6InBybyIsInVzZXJuYW1lIjoiVGVzdCBEZXYifSwibmlja25hbWUiOiJ0ZXN0ZGV2MCIsIm5hbWUiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvOTViMTljNWI1ODBhOTVjNjk5YTQ2ODg3OWE4MmUwYTQ_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ0ZS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyNC0wMy0yMFQxODoxNjo0MS42ODZaIiwiZW1haWwiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlzcyI6Imh0dHBzOi8vbW9lbWF0ZS1kZXYudXMuYXV0aDAuY29tLyIsImF1ZCI6IlIzOTBCNFNMdnA2OTRTWmN4T2NEYk1Pd3NFdDd0ZWJBIiwiaWF0IjoxNzEwOTk3Nzc2LCJleHAiOjE3MTEwMzM3NzYsInN1YiI6ImF1dGgwfDY1Zjg3N2I5NWMyY2QxNGNmYmQzMDU1NyIsInNpZCI6Ii1SSW5aUnBUdlpuTWhaTk0zQlpaRG8zRjNCTGY2UTh6In0.SIjqQLKPmQt-BIzm3u2D-UWO9WVALOaV2Sl8mbmUHDxmnLRiN0e2FM62RJJb3CIgdjxDKXnSYOmchAvyujETbsd9-mNVdAjj3kZTnRfunPjdwN1zzdBBpG17mAfqHKEDeHSDxM5VIo2SP5dhP7qzbRDpyf-1vUs3lPNX8Qv7OXeeTrNsBJ9dmwRvqdLY9cNzZYfy0Y6y7iIs6re3_6axBWTSRv-VqvlbisQCHG2lXRNTiO0ozm8ehsYJX1mwyrksn2_5WbP92AB_PeAtpA2JePpNFBKmpyPXxEKN4mvspGQGtXQNzzpFXwcn3VAi1g_Tj0ndVvAGJJQ2QNi-jUrizg",
    'Content-Length': data.to_json.length
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri)
  request.body = data.to_json
  headers.each { |key, value| request[key] = value }

  response = http.request(request)

  if response.code == '200'
    return JSON.parse(response.body)["generated_text"]
  else
    raise "Failed to make chat API request. Response code: #{response.code}"
  end
end

bot.message do |event|
  if event.message.attachments.first
    attachment = event.message.attachments.first
    file_path = attachment.filename
    uri = URI.parse(attachment.url)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      open(file_path, 'wb') do |file|
        file.write(response.body)
      end
    end

    image = MiniMagick::Image.open(file_path)

    processed_file_path = 'processed_image.jpg' 
    image.write(processed_file_path)

    tags = get_image_tags(processed_file_path)

    response = generate_text("Please generate response with help of these key words #{tags}")

    event.respond response

    File.delete(file_path)
    File.delete(processed_file_path)
  elsif event.message.content
    inputs = event.message.content.to_s
    generated_text = generate_text(inputs)
    
    if generated_text
      event.respond "#{generated_text}"
    else
      event.respond "Failed to generate text."
    end
  else
    event.respond "Failed to generate text."
  end
end

bot.run
