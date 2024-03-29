class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :check_admin_permission
    
    def listing
        if !current_user.admin?
            redirect_to root_path, notice: "No permission for you!"
        end
        
        @products = Product.includes(:store)
    end
end
