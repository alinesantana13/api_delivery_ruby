class OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :chech_admin, only: [:edit, :update]
  before_action :buyer_or_admin
  before_action :set_store, only: [:show]

  def new
    @order = Order.new

    @buyers = User.where(role: :buyer)
  end

  def create
    @order = Order.new(order_params) { |o| o.buyer = current_user }

    if @order.save
      render :create, status: :created
    else
      render json: {errors: @order.errors, status: :unprocessable_entity}
    end
  end

  def index
    page = params.fetch(:page, 1)
    if is_buyers!
      @orders = Order.where(buyer: current_user).page(page)
    end
    @orders = Order.includes(:user, :store).page(page)
  end

  def show
    if is_buyers!
      @order_buyer = @order.find_by(buyer: current_user.id)
      if @order_buyer.nil?
        render json: {message: "Not found order"}, status: :forbidden
      end
      render json: @order_buyer, status: :ok
    end
    respond_to do |format|
      format.html { redirect_to order_url }
    end
  end

  def edit
    @buyers = User.where(role: :buyer)
  end

  def update
    @order.update(order_params)
  end

  # def destroy
  #   @order.discard
  # end

  private
  def order_params
    params.require(:order).permit([:store_id])
  end

  def set_store
    @order = Order.find_by(id: params[:id])
    if @order.nil?
      respond_to do |format|
        format.html { redirect_to orders_url, notice: "Error." }
        format.json { render json: {message: "Order not found"}, status: :not_found}
      end
    end
  end

  def buyer_or_admin
    if !is_admin! && !is_buyers! && current_user.id != @store.user_id
      render json: {message: "Not authorizeaaad"}, status: :unauthorized
    end
  end

  def chech_admin
    if !is_admin!
      render json: {message: "User does not have permission!"}, status: :forbidden
    end
  end
end
