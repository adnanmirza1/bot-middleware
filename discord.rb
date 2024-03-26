require './image_to_text'
require './audio_to_text'
require './text_to_audio'
require 'discordrb'
require 'mini_magick'
require 'net/http'
require 'json'

GENERATE_TEXT_API_URL = 'https://ai.dev.moemate.io/api/chat'.freeze
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

def download_attachment(uri, filename)
  file_path = filename
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    open(file_path, 'wb') do |file|
      file.write(response.body)
    end
  end
  file_path
end

def delete_file(file_path)
  File.delete(file_path) if File.exist?(file_path)
end

def process_image(file_path)
  processed_file_path = 'processed_image.jpg'
  image = MiniMagick::Image.open(file_path)

  # Save processed image
  image.write(processed_file_path)

  processed_file_path
end

tokens = get_discord_tokens
bots = []

tokens.each do |token|
  bot = Discordrb::Bot.new token: token
  bots.push(bot)
end

bots.each do |bot|
  bot.message do |event|
    attachment = event.message.attachments.first

    if attachment
      filename = attachment.filename.downcase
      uri = URI.parse(attachment.url)

      case
      when filename.end_with?('.ogg')
        file_path = download_attachment(uri, filename)

        # Process the voice file (e.g., transcribe)
        transcribed_text = upload_audio_file(file_path)

        # generate text response
        response = generate_text(transcribed_text)
        
        # convert text to audio
        audio = convert_text_to_speech(response)
      
        # send audio to bot
        event.send_file(File.open(audio))

        delete_file(file_path)
      when filename.end_with?('.jpg', '.jpeg', '.png')
        file_path = download_attachment(uri, filename)
        processed_file_path = process_image(file_path)

        # Generate response based on processed image
        tags = get_image_tags(processed_file_path)
        response = generate_text("Please generate response with help of these key words #{tags}")

        event.respond response

        delete_file(file_path)
        delete_file(processed_file_path)

      end
    elsif event.message.content
      inputs = event.message.content.to_s
      generated_text = generate_text(inputs)
      
      if generated_text
        event.respond generated_text
      else
        event.respond "Failed to generate text."
      end
    else
      event.respond "Failed to generate text."
    end
  end

  bot.run
end

