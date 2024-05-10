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

TOKEN = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlMzLUstVWhieEtHYnExbF8tbEloMiJ9.eyJhcHBfbWV0YWRhdGEiOnsiZGlzY29yZF9hY2Nlc3NfdG9rZW4iOiJDV24xOXZXcUlJNktGMmRxampkUmFmRmR1OHN4Nk4iLCJkaXNjb3JkX3JlZnJlc2hfdG9rZW4iOiJUQVBUMWhJVXhxYXNUVEd4VWI3MEVqeDhTc2IxYlAiLCJkaXNjb3JkX3Rva2VuX2NyZWF0ZWRfYXQiOiJGcmkgQXByIDI2IDIwMjQiLCJzdHJpcGVfY3VzdG9tZXJfaWQiOiJjdXNfUHdSNjl3WG9BQ0htUU8iLCJzdWJfcHJvdmlkZXIiOiJzdHJpcGUiLCJzdWJfc3RhdHVzIjoicHJvIiwidHdpdHRlcl9hY2Nlc3NfdG9rZW4iOiJVbFZrTjNGNE16aEdkMnRrWDBWRVdGOWZaalpCVVhsclVHMWxNbW90WVc1TFgxWjZkWEpDTkdsblFtUTJPakUzTVRNME16Z3dPVEUyT0RrNk1Ub3dPbUYwT2pFIiwidHdpdHRlcl9yZWZyZXNoX3Rva2VuIjoiVFhsUWFrOWphRkZJWWpVeFNUUk1lVTFLWm5OUFZqUjRXRGgwYTFGcmJ6UnhNVEZwUkUweFlYQlNXVmM0T2pFM01UTTBNemd3T1RFMk9EazZNVG94T25KME9qRSIsInR3aXR0ZXJfdG9rZW5fY3JlYXRlZF9hdCI6IlRodSBBcHIgMTggMjAyNCIsInR3aXR0ZXJfdXNlcl9pZCI6IjE3NzU4MTg4MTUxNzcxNTA0NjQiLCJ1c2VybmFtZSI6IkFkbmFuMSJ9LCJnaXZlbl9uYW1lIjoiQWRuYW4iLCJmYW1pbHlfbmFtZSI6Ik11c3RhZmEiLCJuaWNrbmFtZSI6ImFkbmFuIiwibmFtZSI6IkFkbmFuIE11c3RhZmEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jS0EzVkpPdE1iWFV3WUFBTWFTQnJIMGRSY3ZyU1ljT0hVUGZpbXdVbUJoWVRieUVRPXM5Ni1jIiwibG9jYWxlIjoiZW4iLCJ1cGRhdGVkX2F0IjoiMjAyNC0wNS0wOVQxMjowNjozNS43ODZaIiwiZW1haWwiOiJhZG5hbkB3ZWJhdmVyc2UuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzcyI6Imh0dHBzOi8vbW9lbWF0ZS1kZXYudXMuYXV0aDAuY29tLyIsImF1ZCI6IlIzOTBCNFNMdnA2OTRTWmN4T2NEYk1Pd3NFdDd0ZWJBIiwiaWF0IjoxNzE1MzQwOTkwLCJleHAiOjE3MTUzNzY5OTAsInN1YiI6Imdvb2dsZS1vYXV0aDJ8MTEwOTY0NTUzNDcyNTM2MzE1MTY3Iiwic2lkIjoiMUJPaGp5RlYzOG9WZGFVUklVVXRiSTdCaDFlVmlMWEkifQ.c8bYoTp1-nkXYl3xPubdw_tAyl42QJj8Q9bJiZQX9AtSV9jrhHhJktFa76n_Gh20h_P7rpmPPkC2Lm0bVBRrbE0UEq2efl5Z7jZ21UPhjyuHRVYeQfZlkklq8EBOJQpShsP66YMo6kmW7dJhfOafm5vySPMU8NmdGytiDXBtQuEEaDD3D2sOjrzmKR5p4KpTZTa0tvkGm36ZQMe2qLtCmkDLghYhqOjrBkY6Zw1gBpX7rHvR4lqmiQGuAZIjazMKI35NSq0Hu1oco5sonk8QDj242tb-aX1P6q1xfcqjr4tSLhdPbRlWbK0ye3EoAE9BdQ7R2Swk3c8_Dy0Y7AQjaA"

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
      handle_message(event, char)
    end

    bot.run
  end
end

# Handle Discord message
def handle_message(event, char)
  attachment = event.message.attachments.first

  if attachment
    filename = attachment.filename.downcase
    uri = URI.parse(attachment.url)

    case
    when filename.end_with?('.ogg')
      process_voice_message(event, char, uri, filename)
    when filename.end_with?('.jpg', '.jpeg', '.png')
      process_image_message(event, char, uri, filename)
    end
  elsif event.message.content
    process_text_message(event, char)
  else
    event.respond "Failed to generate text."
  end
end

# Process voice message
def process_voice_message(event, char, uri, filename)
  file_path = download_attachment(uri, filename)

  # Process the voice file (e.g., transcribe)
  transcribed_text = upload_audio_file(file_path)

  # generate text response
  response = process_text_message(event, char, {}, transcribed_text)
  
  # convert text to audio
  audio = convert_text_to_speech(response)
  
  # send audio to bot
  event.send_file(File.open(audio))

  # delete downloaded audio files
  delete_file(audio)
  delete_file(file_path)
end

# Process image message
def process_image_message(event, char, uri, filename)
  file_path = download_attachment(uri, filename)
  processed_file_path = process_image(file_path)

  # Generate response based on processed image
  response = get_image_tags(processed_file_path)

  process_text_message(event, char, response) if response['tags']

  delete_file(file_path)
  delete_file(processed_file_path)
end

# Process text message
def process_text_message(event, char, imageContent={}, voice_text=nil)
  result = check_discord_user(event.user)
  if result[:discord_user]
    discord_user = result[:discord_user]
    input_text = event.message.content.to_s if event.message.content.to_s
    input_text = voice_text if voice_text

    messages = UserBot.where(user_id: discord_user.id, bot_id: char['id']).last(4).pluck(:message)
    memories_string = messages.join("\n")
    create_user_messages(discord_user.id, char['id'], "user", input_text) if event.message.content.to_s || voice_text

    character_id = char['characterid']
    character = get_character_by_id(character_id)

    return unless character

    prompt = respond_to_user(character['publish']['author'], character, memories_string, "English (US)", imageContent, input_text)
    puts prompt

    response = generated_text(prompt, character_id)
    create_user_messages(discord_user.id, char['id'], "bot", response)

    return response if voice_text

    event.respond response
  elsif result[:signup_link]
    signup_link = result[:signup_link]
    response = "You are not logged in. Please signup using following link to use discord bot\n\n #{signup_link}"
    event.respond response
  else
    # The result is neither a user nor a link
  end
end

# Run the bot
main
