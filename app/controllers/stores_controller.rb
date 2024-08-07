class StoresController < ApplicationController
  include ActionController::Live
  include ActionView::Helpers::NumberHelper

  skip_forgery_protection only:  %i[ create update destroy]
  before_action :authenticate!
  before_action :not_buyer_permission, only: %i[ create update new destroy  ]
  before_action :set_store, only: %i[ show edit update destroy ]

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { render json: { message: "Store not found"}, status: :not_found }
      format.html { render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found }
    end
  end

  # GET /stores or /stores.json
  def index
    page = params.fetch(:page, 1)
    if current_user.admin?
      @stores = Store.includes(:user).where(deleted_at_timestamp: nil).order(:name).page(page)
    elsif current_user.buyer?
      @stores = Store.where(deleted_at_timestamp: nil).order(:name).page(page)
    else
      @stores = Store.where(user: current_user, deleted_at_timestamp: nil).order(:name).page(page)
    end
  end

  # GET /stores/1 or /stores/1.json
  def show
    if current_user.seller?
      @store = current_user.stores.find_by(id: params[:id], deleted_at_timestamp: nil)
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
    if current_user.admin?
      @sellers = User.where(role: :seller)
    end
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
    begin
      if current_user.admin? || @store.user_id == current_user.id
        @store.update(deleted_at_timestamp: Time.current.to_i)

        respond_to do |format|
          format.html { redirect_to stores_url, notice: "Store was successfully destroyed." }
          format.json { head :no_content  }
        end
      else
        render json: {message: "Store not found!"}, status: :not_found
      end
    rescue StandardError
      respond_to do |format|
        format.html { redirect_to stores_url, notice: "Error."}
        format.json { render json: {error: "Internal server error"}, status: :unprocessable_entity }
      end
    end
  end

  def new_order
    response.headers["Content-Type"] = "text/event-stream"
    sse = SSE.new(response.stream, retry: 300, event: "waiting-orders")
    sse.write({hello: "world!"}, event: "waiting-order")
    EventMachine.run do
      EventMachine::PeriodicTimer.new(3) do
        orders = Order.joins(:store)
                      .where(state: :created,
                      payment_status: ["paid_out", "in_the_delivery"],
                      stores: { user_id: current_user.id })
                      .order(created_at: :desc)
        if orders.any?
          new_orders = orders.map do |order|
            order_items = order.order_items
            items_with_products = order_items.map do |item|
              {
                product_title: item.product.title,
                amount: item.amount,
                price: item.price
              }
            end

            total_price = order_items.sum { |order_item| order_item.price }
            total_order_items = ActionController::Base.helpers.number_to_currency(total_price)

            {
              id: order.id,
              buyer_id: order.buyer_id,
              store_id: order.store_id,
              state: order.state,
              payment_status: order.payment_status,
              created_at: order.created_at,
              total_order_items: total_order_items,
              order_items: items_with_products
            }
          end

          message = { time: Time.now, orders: new_orders }
            sse.write(message, event: "new-order")
        else
          sse.write(message, event: "no")
        end
      end
    end
    rescue IOError, ActionController::Live::ClientDisconnected
      sse.close
    ensure
      sse.close
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.where(id: params[:id], deleted_at_timestamp: nil).first

      if @store.nil?
        respond_to do |format|
          format.html { redirect_to stores_url, notice: "Store not found!" }
          format.json { render json: {message: "Store not found!"}, status: :not_found }
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def store_params
      required = params.require(:store)

      if current_user.admin?
        required.permit(:name, :user_id, :image)
      else
        required.permit(:name, :image)
      end
    end

    def not_buyer_permission
      if current_user.buyer?
        render json: {message: "Not authorized"}, status: :unauthorized
      end
    end
end
