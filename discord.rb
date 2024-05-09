require './config/environment.rb'
require './image_to_text'
require './audio_to_text'
require './text_to_audio'
require './ai_prompt.rb'
require './ai_generation_text.rb'
require './get_character.rb'
require './helpers.rb'
require 'telegram/bot'
require 'mini_magick'
require 'json'
require 'net/http'
require "byebug"

# Download attachment from Discord message
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

# Delete file
def delete_file(file_path)
  File.delete(file_path) if File.exist?(file_path)
end

# Process image using MiniMagick
def process_image(file_path)
  processed_file_path = 'processed_image.jpg'
  image = MiniMagick::Image.open(file_path)

  # Save processed image
  image.write(processed_file_path)

  processed_file_path
end

# Main bot logic
def main
  # Get Discord tokens
  characters = DiscordBot.all

  # Create and run bots for each token
  characters.each do |char|
    bot = Discordrb::Bot.new(token: char['token'])

    bot.message do |event|
      handle_message(event)
    end

    bot.run
  end
end

# Handle Discord message
def handle_message(event)
  attachment = event.message.attachments.first

  if attachment
    filename = attachment.filename.downcase
    uri = URI.parse(attachment.url)

    case
    when filename.end_with?('.ogg')
      process_voice_message(event, uri, filename)
    when filename.end_with?('.jpg', '.jpeg', '.png')
      process_image_message(event, uri, filename)
    end
  elsif event.message.content
    process_text_message(event)
  else
    event.respond "Failed to generate text."
  end
end

# Process voice message
def process_voice_message(event, uri, filename)
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
end

# Process image message
def process_image_message(event, uri, filename)
  file_path = download_attachment(uri, filename)
  processed_file_path = process_image(file_path)

  # Generate response based on processed image
  tags = get_image_tags(processed_file_path)
  response = generate_text("Please generate response with help of these key words #{tags}")

  event.respond response

  delete_file(file_path)
  delete_file(processed_file_path)
end

# Process text message
def process_text_message(event)
  inputs = event.message.content.to_s
  generated_text = generate_text(inputs)
  
  if generated_text
    event.respond generated_text
  else
    event.respond "Failed to generate text."
  end
end

# Run the bot
main
