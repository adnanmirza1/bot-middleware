class UsersController < ApplicationController
  skip_forgery_protection only: [:create_user]

  def home
  end

  def signup
  end

  def create_user
    user = User.find_or_initialize_by(telegram_userid: params[:user_id])
    
    if user.persisted? && user.auth_token == params[:access_token]
      render json: { message: "User already exist" }, status: :ok
    else
      user.auth_token = params[:access_token]
      user.save!
      render json: { message: "User created successfully" }, status: :ok
    end
  end

end
