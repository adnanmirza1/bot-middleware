class TelegramBot < Bot

  def self.ransackable_attributes(auth_object = nil)
    ["characterid", "character_name", "created_at", "id", "token", "type", "updated_at", "bot_user_name"]
  end
  
end