class UsersController < ApplicationController
  skip_forgery_protection only: [:index, :show, :update, :destroy]
  before_action :authenticate!, only: [:index, :show, :update, :destroy]
  before_action :set_user, only: [:show, :update, :destroy]
  rescue_from User::InvalidToken, with: :not_authorized

  # GET /users or /users.json
  def index
    if current_user.admin?
      @users = User.kept
    else
      @users = User.kept.where(id: current_user.id)
    end
  end

  # GET /users/1 or /users/1.json
  def show
    render json: @user_params_id, status: :ok
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    if @user_params_id.update(user_params)
      render json: { message: "User successfully update" }, status: :ok
    else
      render json: { message: "Error updating user" }, status: :unprocessable_entity
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    if @user_params_id.discard
        render json: { message: "User successfully deleted" }, status: :ok
    else
        render json: { message: "Error" }, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params
        .required(:user)
        .permit(:email, :password, :password_confirmation)
  end

  def set_user
    if current_user.id.to_s != params[:id] && !current_user.admin?
      render json: { message: "User does not have permission" }, status: :forbidden
    else
      @user_params_id = User.kept.find_by(id: params[:id])
      if @user_params_id.nil?
        render json: { message: "User not found" }, status: :not_found
      end
    end
  end

end