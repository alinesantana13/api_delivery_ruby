class OrderItemsController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!, :buyer_or_admin
  before_action :set_order

  def index
    @order_items = order_items.scoped
  end

  def show
    @order_items = order_items.find(params[:id])
  end

  def create
    if @order.state != "created"
      respond_to do |format|
        format.html { redirect_to orders_url, notice: "Order cannot be created" }
        format.json { render json: {message: "Order cannot be created"}, status: :not_found}
      end
    else
      @order_item = @order.order_items.build(order_items_params)
      @order_item.price = @order_item.product.price * @order_item.amount

      respond_to do |format|
        if @order_item.save
          format.html { redirect_to order_url(@order), notice: "Order was successfully created." }
          format.json { render json: @order_item, status: :created }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @order_item.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    @order_items = order_items.find(params[:id])
  end

  def edit
    @order_items = order_items.find(params[:id])
  end

  def destroy
    order_items = order_items.find(params[:id])
  end

  private
  def order_items_params
    params.require(:order_item).permit(:product_id, :amount)
  end

  def set_order
    @order = Order.find_by(id: params[:order_id])
    if @order.nil?
      respond_to do |format|
        format.html { redirect_to orders_url, notice: "Error." }
        format.json { render json: {message: "Order not found"}, status: :not_found}
      end
    elsif !is_admin! && @order.buyer_id != current_user.id
      render json: { message: "Not found order_items" }, status: :forbidden
    end
  end

  def buyer_or_admin
    if !is_admin! && !is_buyers!
      render json: {message: "Unauthorized access to order_items"}, status: :unauthorized
    end
  end
end
