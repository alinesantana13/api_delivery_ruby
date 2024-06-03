class ProductsController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!, :set_locale!
  before_action :set_store, except: [:listing]
  before_action :set_product, only: [:edit, :update, :destroy, :show]
  before_action :seller_or_admin, only: [:create, :edit, :update, :destroy]

  #Falta colocar que a credential e obrigatória passar para os perfis de seller e buyer

  def listing
    page = params.fetch(:page, 1)
    if !is_admin!
      redirect_to root_path, notice: "No permission for you!"
    end
    @products = Product.kept.includes(:store).page(page)
  end

  def new
    @product = @store.products.build
  end

  def create
    @product = @store.products.build(product_params)
    if @product.save
      respond_to do |format|
        format.html { redirect_to store_path(@store), notice: "Product was created." }
        format.json { render json: {"id": @product.id, "title": @product.title, "price": @product.price}, status: :created}
      end
    else
      render json: {errors: @product.errors}, status: :unprocessable_entity
    end


  end

  def index
    page = params.fetch(:page, 1)
    if is_buyers! || current_user.admin?
      @products = @store.products.kept.page(page)
    else
      @store = current_user.stores.find_by(id: params[:store_id])
      if @store.present?
        @products = @store.products.kept.page(page)
      else
        render json: { error: "Store not found or not authorized #{is_buyers!}" }, status: :forbidden
      end
    end
  end

  # GET /stores/1/products/1 or /stores/1/products/1.json
  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to [@store, @product], notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  #falta ajustar
  def destroy
    if is_admin!
      if @product.discard
        respond_to do |format|
          format.html { redirect_to store_path(@store), notice: "Product was successfully destroyed." }
          format.json { render json: {message: "Product was successfully destroyed."}, status: :ok}
        end
      else
        respond_to do |format|
          format.html { redirect_to users_url, notice: "Error." }
          format.json { render json: {message: "Error"}, status: :unprocessable_entity}
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

  def set_product
    @product = @store.products.kept.find_by(id: params[:id]) if @store
    if @product.nil?
      respond_to do |format|
        format.html { redirect_to stores_url, notice: "Error." }
        format.json { render json: {message: "Product not found"}, status: :not_found}
      end
    end
  end

  def product_params
    params.require(:product).permit(:title, :price, :image)
  end

  def seller_or_admin
    if !is_admin! && !is_seller! && current_user.id != @store.user_id
      render json: {message: "Not authorizeaaad"}, status: :unauthorized
    end
  end
end
