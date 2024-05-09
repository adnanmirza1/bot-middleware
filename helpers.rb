def check_user(user)
  telegram_user = User.find_by(telegram_userid: user.id)

  if telegram_user && telegram_user.auth_token
    telegram_user.update(username: user.username, first_name: user.first_name, last_name: user.last_name)
    return { telegram_user: telegram_user }
  else
    signup_link = "http://localhost:3000/signup?userid=#{user.id}"
    return { signup_link: signup_link }
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
