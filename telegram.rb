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

TOKEN = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlMzLUstVWhieEtHYnExbF8tbEloMiJ9.eyJhcHBfbWV0YWRhdGEiOnsiZGlzY29yZF9hY2Nlc3NfdG9rZW4iOiJDV24xOXZXcUlJNktGMmRxampkUmFmRmR1OHN4Nk4iLCJkaXNjb3JkX3JlZnJlc2hfdG9rZW4iOiJUQVBUMWhJVXhxYXNUVEd4VWI3MEVqeDhTc2IxYlAiLCJkaXNjb3JkX3Rva2VuX2NyZWF0ZWRfYXQiOiJGcmkgQXByIDI2IDIwMjQiLCJzdHJpcGVfY3VzdG9tZXJfaWQiOiJjdXNfUHdSNjl3WG9BQ0htUU8iLCJzdWJfcHJvdmlkZXIiOiJzdHJpcGUiLCJzdWJfc3RhdHVzIjoicHJvIiwidHdpdHRlcl9hY2Nlc3NfdG9rZW4iOiJVbFZrTjNGNE16aEdkMnRrWDBWRVdGOWZaalpCVVhsclVHMWxNbW90WVc1TFgxWjZkWEpDTkdsblFtUTJPakUzTVRNME16Z3dPVEUyT0RrNk1Ub3dPbUYwT2pFIiwidHdpdHRlcl9yZWZyZXNoX3Rva2VuIjoiVFhsUWFrOWphRkZJWWpVeFNUUk1lVTFLWm5OUFZqUjRXRGgwYTFGcmJ6UnhNVEZwUkUweFlYQlNXVmM0T2pFM01UTTBNemd3T1RFMk9EazZNVG94T25KME9qRSIsInR3aXR0ZXJfdG9rZW5fY3JlYXRlZF9hdCI6IlRodSBBcHIgMTggMjAyNCIsInR3aXR0ZXJfdXNlcl9pZCI6IjE3NzU4MTg4MTUxNzcxNTA0NjQiLCJ1c2VybmFtZSI6IkFkbmFuMSJ9LCJnaXZlbl9uYW1lIjoiQWRuYW4iLCJmYW1pbHlfbmFtZSI6Ik11c3RhZmEiLCJuaWNrbmFtZSI6ImFkbmFuIiwibmFtZSI6IkFkbmFuIE11c3RhZmEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jS0EzVkpPdE1iWFV3WUFBTWFTQnJIMGRSY3ZyU1ljT0hVUGZpbXdVbUJoWVRieUVRPXM5Ni1jIiwibG9jYWxlIjoiZW4iLCJ1cGRhdGVkX2F0IjoiMjAyNC0wNS0wNlQwODowNzowOC45ODRaIiwiZW1haWwiOiJhZG5hbkB3ZWJhdmVyc2UuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzcyI6Imh0dHBzOi8vbW9lbWF0ZS1kZXYudXMuYXV0aDAuY29tLyIsImF1ZCI6IlIzOTBCNFNMdnA2OTRTWmN4T2NEYk1Pd3NFdDd0ZWJBIiwiaWF0IjoxNzE1MDc4MzIyLCJleHAiOjE3MTUxMTQzMjIsInN1YiI6Imdvb2dsZS1vYXV0aDJ8MTEwOTY0NTUzNDcyNTM2MzE1MTY3Iiwic2lkIjoiU2pyNHJNVjFHbjM4QlpkQ2NRRmRDVlcycjdTX19VdFIifQ.hJobxhQoI_T8lQNtFopWLJSa4XjRdbcMgAPsF7O5JDcMP8P5vT41Qe38b1OTZeUZA3kd5QKEQ2g7z4koaDHZewUk9XQwqx3d2vtWYx9aEX13Qnq3C24JirfXkNR7h6XRB_hrDC0UtF2msmHokKaiEHgn50OmcUN5yWKGwg_-5JeV2vxw_FiotEJjH5dwzxQYbjn5_9qX64UOODtxmmuF5jgT0nBPRa41PZ8CXRQreQSa_9Qxv3aQarsK0MePTee6SUKS8wTWj2quEvxyIEDp4dKuY9mpQqIyJ23BP2gC_ajkq1NJyE3_TRA-lsbGerT9YEi4SctnWStK5qTsl3UlAQ"

def download_attachment(file_path, file, token)
  begin
    puts "File object: #{file.inspect}"

    if file.file_path
      uri = URI.parse("https://api.telegram.org/file/bot#{token}/#{file.file_path}")
      
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri)
        response = http.request(request)

        open(file_path, 'wb') do |file|
          file.write(response.body)
        end
      end

      puts "File downloaded successfully: #{file_path}"
      return file_path
    else
      puts "File object does not contain 'file_path' key"
    end
  rescue StandardError => e
    puts "Error downloading voice message: #{e.message}"
    puts e.backtrace.join("\n")
  end
end

def process_voice_message(message, bot, char)
  token = bot.instance_variable_get('@api').token
  voice_file_id = message.voice.file_id
  file = bot.api.get_file(file_id: voice_file_id)
  download_file_path = "audio_file_#{Date.new}.ogg";
  file_path = download_attachment(download_file_path, file, token)

  transcribed_text = upload_audio_file(file_path)
  puts transcribed_text

  # generate text response
  response = process_text_message(message, bot, char, {}, transcribed_text)
  
  # convert text to audio
  audio = convert_text_to_speech(response)
  
  # send audio to bot
  data = File.read(audio)
  bot.api.send_voice(chat_id: message.chat.id, voice: Faraday::UploadIO.new(StringIO.new(data), 'audio/ogg'))

  delete_file(audio)
  delete_file(file_path)
end

def process_image(file_path)
  processed_file_path = 'processed_image.jpg'
  image = MiniMagick::Image.open(file_path)

  # Save processed image
  image.write(processed_file_path)

  processed_file_path
end

def process_image_message(message, bot, char)
  token = bot.instance_variable_get('@api').token
  photo_file_id = message.photo[0].file_id
  file = bot.api.get_file(file_id: photo_file_id)
  download_file_path = "image_file_#{Date.new}.png";
  file_path = download_attachment(download_file_path, file, token)
  processed_file_path = process_image(file_path)

  # Generate response based on processed image
  response = get_image_tags(processed_file_path)

  process_text_message(message, bot, char, response) if response['tags']
  # event.respond response

  delete_file(file_path)
  delete_file(processed_file_path)
end

def delete_file(file_path)
  File.delete(file_path) if File.exist?(file_path)
end

def process_message(message, bot, char)
  case message
  when Telegram::Bot::Types::Message
    if message.voice
      process_voice_message(message, bot, char)
    elsif message.photo
      process_image_message(message, bot, char)
    else
      process_text_message(message, bot, char)
    end
  end
end

def process_text_message(message, bot, char, imageContent = {}, voice_text=nil)
  result = check_user(message.from)
  if result[:telegram_user]
    telegram_user = result[:telegram_user]
    input_text = message.text if message.text
    input_text = voice_text if voice_text

    messages = UserBot.where(user_id: telegram_user.id, bot_id: char['id']).last(4).pluck(:message)
    memories_string = messages.join("\n")
    create_user_messages(telegram_user.id, char['id'], "user", input_text) if message.text || voice_text

    character_id = char['characterid']
    character = get_character_by_id(character_id)

    return unless character

    prompt = respond_to_user(character['publish']['author'], character, memories_string, "English (US)", imageContent, input_text)
    puts prompt

    response = generated_text(prompt, character_id)
    create_user_messages(telegram_user.id, char['id'], "bot", response)

    return response if voice_text

    bot.api.send_message(chat_id: message.chat.id, text: response)
  elsif result[:signup_link]
    signup_link = result[:signup_link]
    response = "You are not logged in. Please signup using following link to use telegram bot\n\n #{signup_link}"
    bot.api.send_message(chat_id: message.chat.id, text: response)
  else
    # The result is neither a user nor a link
  end
end

characters = TelegramBot.all

characters.each do |char|
  Thread.new do
    Telegram::Bot::Client.run(char['token']) do |bot|
      puts "Bot is running"
      bot.listen do |message|
        process_message(message, bot, char)
      end
    end
  end
end

# Sleep to keep the main thread alive
sleep
