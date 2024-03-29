class ProductsController < ApplicationController
    before_action :authenticate_user!
    
    def listing
    
        @products = Product.includes(:store)
    end
end
