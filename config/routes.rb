Rails.application.routes.draw do
  get '/get_tokens', to: 'telegram_bots#get_tokens'
  get '/get_discord_tokens', to: 'telegram_bots#get_discord_tokens'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
