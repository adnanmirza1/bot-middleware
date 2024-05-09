Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'users#home'
  get 'signup', to: 'users#signup'
  post 'create_user', to: 'users#create_user'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
