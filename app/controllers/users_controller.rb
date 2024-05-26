class UsersController < ApplicationController
  skip_forgery_protection only: [:show, :update, :destroy]
  before_action :authenticate!
  before_action :set_user, only: [:show, :update, :destroy, :edit]
  before_action :is_admin!, only: [:index, :new, :create]
  rescue_from User::InvalidToken, with: :not_authorized

  # GET /users/new
  def new
    @user_new = User.new
    @roles = User.roles.keys
  end

  #POST users/create
  def create
    @user_new = User.new(user_params)

    respond_to do |format|
      if @user_new.save
        format.html { redirect_to user_url(@user_new), notice: "User was successfully created." }
      else
        puts @user_new.errors.full_messages
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # GET /users or /users.json
  def index
    page = params.fetch(:page, 1)
    @users = User.kept.where.not(id: current_user.id).order(:email).page(page)
  end

  # GET /users/1 or /users/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json
    end
  end

  # GET /users/1/edit
  def edit
    @roles = User.roles.keys
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    respond_to do |format|
      if @user_params_id.update(user_params)
        format.html { redirect_to user_url(@user_params_id), notice: "User was successfully updated." }
        format.json { render json: {message: "User successfully update"}, status: :ok }
      else
        format.html { render :edit, notice: "User was successfully update.", status: :unprocessable_entity }
        format.json { render json: @user_params_id.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    respond_to do |format|
      if @user_params_id.discard
        format.html { redirect_to users_url, notice: "User was successfully deleted." }
        format.json { render json: {message: "User successfully deleted"}, status: :ok}
      else
        format.html { redirect_to users_url, notice: "Error." }
        format.json { render json: {message: "Error"}, status: :unprocessable_entity}
      end
    end
  end

  private
  def user_params
    params
        .required(:user)
        .permit(:email, :password, :password_confirmation, :role)
  end

  def set_user
    if current_user.id.to_s != params[:id] && !current_user.admin?
      render json: {message: "User does not have permission!"}, status: :forbidden
    else
      @user_params_id = User.kept.find_by(id: params[:id])
        if @user_params_id.nil?
          respond_to do |format|
          format.html { redirect_to users_url, notice: "User not found!" }
          format.json { render json: {message: "User not found!"}, status: :not_found}
        end
      end
    end
  end
end
