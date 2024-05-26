class ProductsController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :set_locale!
  before_action :set_store
  before_action :check_owner, only: [:create]

  #Falta colocar que a credential e obrigatória passar para os perfis de seller e buyer

  def listing
    if !current_user.admin?
      redirect_to root_path, notice: "No permission for you!"
    end
    @products = Product.includes(:store)
  end

  def create
    @product = @store.products.build(product_params)
    if @product.save
      render json: {"id": @product.id, "title": @product.title, "price": @product.price}, status: 201
    else
      render json: {errors: @product.errors}, status: :unprocessable_entity
    end
  end

  def index
    page = params.fetch(:page, 1)
    if is_buyers! || current_user.admin?
      @products = Product.where(store_id: params[:store_id])
        .order(:title).page(page)
    else
      @store = current_user.stores.find_by(id: params[:store_id])
      if @store.present?
        @products = @store.products.page(page)
      else
        render json: { error: "Store not found or not authorized #{@store.id}" }, status: :forbidden
      end
    end
  end

  # GET /stores/1/products/1 or /stores/1/products/1.json
  def show
    if current_user.admin?
      @product = Product.where(id: params[:id], store_id: params[:store_id])
        .order(:title)
      if @store.nil?
        render json: { message: "Store not found"}, status: :not_found
      end
    end
  end

  def edit
  end

  def destroy
    if only_admin!
      @product = Product.where(id: params[:id], store_id: params[:store_id])
      if @product.discard
        respond_to do |format|
          format.html { redirect_to request.referer, notice: "Product was successfully destroyed." }
        end
      else
        respond_to do |format|
          format.html { redirect_to request.referer, alert: 'Error deleting product.' }
        end
      end
    end
  end

  private
  def set_store
    begin
      @store = Store.find(params[:store_id])
    rescue
      render json: {message: "Not Found"}, status: 404
    end
  end

  def product_params
    params.require(:product).permit(:title, :price)
  end

  def check_owner
    if current_user.id != @store.user_id
      render json: {message: "Not authorized"}, status: :unauthorized
    end
  end
end
