def create_telegram_user(user)
  telegram_user = TelegramUser.find_or_initialize_by(telegram_userid: user.id)

  # Update other attributes if the user already exists
  if telegram_user.persisted?
    return telegram_user
  else
    telegram_user.attributes = { username: user.username, first_name: user.first_name, last_name: user.last_name }
  end

  if telegram_user.save
    return telegram_user
  else
    return "User not created: #{telegram_user.errors.full_messages.join(', ')}"
  end
end

def create_user_messages(user_id, character_id, type, msg)
  message = UserBot.new(user_id: user_id, bot_id: character_id, user_type: type, message: msg)
  
  if message.save
    return "message created successfully"
  else
    "message not created #{message.errors.full_messages.join(', ')}"
  end
end
