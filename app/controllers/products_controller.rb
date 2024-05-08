class ProductsController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :set_store
  before_action :check_owner, only: [:create]

    
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
      @product = @store.products.all
      render json: {products: @product}, status: :ok
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
