class OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :chech_admin, only: [:new, :edit]
  before_action :buyer_or_admin, only: [:show, :create, :update]
  before_action :set_order, only: [:show, :update, :accept, :prepare, :start_delivery, :deliver, :cancel]
  before_action :seller_or_admin, only: [:accept, :prepare, :start_delivery, :deliver]

  def new
    @order = Order.new

    @buyers = User.where(role: :buyer)
  end

  def create
    @order = Order.new(order_params) { |o| o.buyer = current_user }

    respond_to do |format|
      if @order.save
        format.html { redirect_to order_url(@order), notice: "Order was successfully created." }
        format.json { render json: @order, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    page = params.fetch(:page, 1)
    if is_buyers!
      @orders = Order.where(buyer_id: current_user.id).page(page)
    elsif is_seller!
      @orders = Order.joins(:store).where(store: { user_id: current_user.id }).page(page)
    else
      @orders = Order.includes(:user, :store).page(page)
    end
  end

  def show
    if !is_admin! && @order.buyer_id != current_user.id
      render json: { message: "Not found order" }, status: :forbidden
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

  #state
  def update_state(state, success_message, error_message)
    if @order.send("#{state}")
      respond_to do |format|
        format.html { render :show, notice: success_message }
        format.json { render json: { message: success_message }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :show, notice: error_message }
        format.json { render json: { message: error_message }, status: :unprocessable_entity }
      end
    end
  end

  def finished
    update_state(:finished, "Order was ready for store.", "Failed to ready for store order.")
  end

  def accept
    update_state(:accept, "Order was accepted.", "Failed to accept order.")
  end

  def prepare
    update_state(:prepare, "Order is being prepared.", "Failed to prepare order.")
  end

  def start_delivery
    update_state(:start_delivery, "Order is out for delivery.", "Failed to start delivery for order.")
  end

  def deliver
    update_state(:deliver, "Order has been delivered.", "Failed to deliver order.")
  end

  def cancel
    update_state(:cancel, "Order has been canceled.", "Failed to cancel order.")
  end

  private
  def order_params
    params.require(:order).permit([:store_id])
  end

  def set_order
    @order = Order.includes(order_items: :product).find_by(id: params[:id])
    if @order.nil?
      respond_to do |format|
        format.html { redirect_to orders_url, notice: "Error." }
        format.json { render json: {message: "Order not found"}, status: :not_found}
      end
    end
  end

  def buyer_or_admin
    if !is_admin! && !is_buyers!
      render json: {message: "Unauthorized access to order"}, status: :unauthorized
    end
  end

  def seller_or_admin
    if !is_admin! && (@order.store.user_id != current_user.id || !is_seller!)
      render json: {message: "Unauthorized access state to order"}, status: :unauthorized
    end
  end

  def chech_admin
    if !is_admin!
      render json: {message: "User does not have permission!"}, status: :forbidden
    end
  end
end
