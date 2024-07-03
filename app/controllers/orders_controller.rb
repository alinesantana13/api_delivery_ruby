class OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :chech_admin, only: [:new, :edit]
  before_action :buyer_or_admin, only: [:show, :create]
  before_action :set_order, only: [:show, :update]

  def new
    @order = Order.new

    @buyers = User.where(role: :buyer)
  end

  def create
    ActiveRecord::Base.transaction do
      @order = Order.new(order_params) { |o| o.buyer = current_user }

      if @order.save
        params[:order_items].each do |item_params|
          product = Product.find(item_params[:product_id])
          price = product.price * item_params[:amount]
          @order_item = @order.order_items.create!(item_params.permit(:product_id, :amount).merge(price: price))
        end

        pay_now = ActiveModel::Type::Boolean.new.cast(params[:pay_now])

        if pay_now
          payment_status = process_payment
          Rails.logger.info "Payment status: #{payment_status}"
          if payment_status
            @order.update!(payment_status: :paid_out, state: :created)
          else
            @order.update!(payment_status: :failed, state: :canceled)
          end
        else
          @order.update!(payment_status: :in_the_delivery, state: :created)
        end

        @order.save!

        respond_to do |format|
          if @order.payment_status == "paid_out" || @order.payment_status == "in_the_delivery"
            format.html { redirect_to order_url(@order), notice: "Order was successfully created." }
            format.json { render json: @order, status: :created }
          else
            format.html { redirect_to order_url(@order), alert: "Order was created but payment failed." }
            format.json { render json: { order: @order, message: "Order was created but payment failed." }, status: :created }
          end
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
    end
  rescue ActiveRecord::RecordInvalid, StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def index
    page = params.fetch(:page, 1)
    state_filter = params[:state]
    id_filter = params[:id]

    if is_buyers!
      @orders = Order.where(buyer_id: current_user.id).page(page)
    elsif is_seller!
      @orders = Order.joins(:store).where(store: { user_id: current_user.id }).page(page)
    else
      @orders = Order.includes(:user, :store).page(page)
    end

    @orders = @orders.where(state: state_filter) if state_filter.present?
    @orders = @orders.where(id: id_filter) if id_filter.present?
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
    if params[:state].present? && @order.respond_to?("#{params[:state]}!")
      if @order.send("#{params[:state]}!")
        render json: @order, status: :ok
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["Invalid state transition requested"] }, status: :unprocessable_entity
    end
  rescue StateMachines::InvalidTransition => e
    render json: { errors: [e.message] }, status: :unprocessable_entity
  end

  # def destroy
  #   @order.discard
  # end

  private
  def order_params
    params.require(:order).permit([:store_id])
  end

  def process_payment
    debugger
    payment_params = params.require(:payment).permit(:value, :number, :valid, :cvv)
    begin
      @payment = PaymentJob.new.perform(order: @order, value: payment_params[:value],
                             number: payment_params[:number],
                             valid: payment_params[:valid],
                             cvv: payment_params[:cvv])
      if @payment.status == 200
        return true
      else
        return false
      end
    rescue Faraday::ConnectionFailed => e
      Rails.logger.error "Payment connection failed: #{e.message}"
      return false
    rescue StandardError => e
      Rails.logger.error "Payment failed: #{e.message}"
      return false
    end
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
