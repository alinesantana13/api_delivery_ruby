class ApplicationController < ActionController::Base

    def authenticate!
        if request.format == Mime[:json]
            check_token!
        else
            authenticate_user!
        end
    end

    def current_user
        if request.format == Mime[:json]
            @user
        else
            super
        end
    end

    private
    
    def check_token!
        begin
            if user = authenticate_with_http_token { |t, _| User.from_token(t) }
                @user = user
            else
                render json: {message: "Not authorized"}, status: 401
            end
        rescue
            render json: {message: "Not authorized"}, status: 401
        end
    end

    def current_credential
        return nil if request.format != Mime[:json]
        Credential.find_by(key: request.headers["X-API-KEY"]) || Credential.new
    end

    def only_buyers!
        is_buyer = (current_user && current_user.buyer?) && current_credential.buyer?

        if !is_buyer
            render json: {message: "Not authorized"}, status: 401
        end
    end
end
