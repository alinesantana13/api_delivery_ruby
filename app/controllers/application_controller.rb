class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session

    def authenticate!
        if request.format == Mime[:json]
            check_token!
        else
            authenticate_user!
        end
    end

    private
    
    def check_token!
        if user = authenticate_with_http_token { |t, _| User.from_token(t) }
        else
            render json: {message: "Not authorized"}, status: 401
        end
    end

end
