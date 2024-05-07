ActiveAdmin.register DiscordBot do

  permit_params :token, :bot_user_name, :type, :character_name, :characterid

  index do
    selectable_column
    id_column
    column :token
    column :bot_user_name
    column :type
    column :character_name
    column :characterid
    actions defaults: true do |discord|
      link_to 'Talk to Bot', "https://web.telegram.org/k/#@#{discord.bot_user_name}", target: '_blank' if discord.bot_user_name.present?
    end
  end

  filter :token
  filter :bot_user_name
  filter :type
  filter :character_name
  filter :characterid

  form do |f|
    f.inputs do
      f.input :token
      f.input :bot_user_name
      f.input :type
      f.input :character_name
      f.input :characterid
    end
    f.actions
  end
end
