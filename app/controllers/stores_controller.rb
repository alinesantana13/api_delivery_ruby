class StoresController < ApplicationController
  skip_forgery_protection only:  %i[ create update ]
  before_action :authenticate!
  before_action :set_store, only: %i[ show edit update destroy ]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { render json: { message: "Store not found"}, status: :not_found }
      format.html { render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found }
    end
  end

  # GET /stores or /stores.json
  def index
    if current_user.admin?
      @stores = Store.includes(:user).all
    elsif current_user.buyer?
      @stores = Store.all
    else
      @stores = Store.where(user: current_user)
    end
  end

  # GET /stores/1 or /stores/1.json
  def show
    if  !current_user.admin?
      @store = current_user.stores.find_by(id: params[:id])
      if @store.nil?
        render json: { message: "Store not found"}, status: :not_found
      end
    end
  end

  # GET /stores/new
  def new
    @store = Store.new

    if current_user.admin?
      @sellers = User.where(role: :seller)
    end
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores or /stores.json
  def create
    @store = Store.new(store_params)
    if !current_user.admin?
      @store.user = current_user
    end

    respond_to do |format|
      if @store.save
        format.html { redirect_to store_url(@store), notice: "Store was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stores/1 or /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to store_url(@store), notice: "Store was successfully updated." }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1 or /stores/1.json
  def destroy
    @store.destroy!

    respond_to do |format|
      format.html { redirect_to stores_url, notice: "Store was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def store_params
      required = params.require(:store)

      if current_user.admin?
        required.permit(:name, :user_id)
      else
        required.permit(:name)
      end
    end
end
