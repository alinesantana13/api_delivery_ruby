class RegistrationsController < ApplicationController
    skip_forgery_protection only: [:create,  :sign_in, :me, :logout, :canceluser, :unlockuser, :storeslist]
    before_action :authenticate!, only: [:me]
    rescue_from User::InvalidToken, with: :not_authorized

    def storeslist
        @stores = Store.all;
        render json: {"stores": @stores}
    end

    def create
        begin
            @user = User.new(user_params)
            if @user.save
                render json: {"email": @user.email}
            else
                if @user.errors[:email].include?("has already been taken")
                    render json: { error: "The email already exists" }, status: :bad_request
                else
                    render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
                end
            end
        rescue StandardError => e
            render json: { error: "#{e.message}" }, status: :internal_server_error
        end
    end

    def sign_in
        user = User.find_by(email: sign_in_params[:email])

        if !user || !user.valid_password?(sign_in_params[:password])
            render json: {message: "Incorrect email or password!"}, status: 401
        else
            cancel_user1 = CancelUsers.find_by(user_id: user.id)
            if cancel_user1.present?
                render json: {message: "Not access"}, status: 401
            else
                token = User.token_for(user)
            render json: {email: user.email, token: token}
            end  
        end
    end

    def me
        token = request.headers['Authorization']&.split(' ')&.last

        decoded_token = JWT.decode token, Rails.application.credentials.secret_hash_jwt, true, {algorithm: "HS256"}
        payload = decoded_token.first
        user_id = payload['id']
        user_email = payload['email']

        token_logout_db = TokenLogout.find_by(token: token)

        if token_logout_db.present?
            render json: {"message": "User needs to log in"}
        else
            render json: {id: user_id, email: user_email}
        end
    end

    def logout
        token = request.headers['Authorization']&.split(' ')&.last

        token_logout_db = TokenLogout.find_by(token: token)

        if token_logout_db.present?
            render json: {"message": "User has already been logged out"}
        else
            token_logout_create_db = TokenLogout.create(token: token)
            render json: {"message": "User successfully logged out"}
        end

        #verifica se o tempo do token expirou
        # decoded_token= JWT.decode token, Rails.application.credentials.secret_hash_jwt, true, {algorithm: "HS256"}
        # exp_timestamp = decoded_token.first['exp'].to_i
        # current_timestamp = Time.now.to_i 
    end

    def canceluser
        token = request.headers['Authorization']&.split(' ')&.last
        decoded_token = JWT.decode token, Rails.application.credentials.secret_hash_jwt, true, {algorithm: "HS256"}
        payload = decoded_token.first
        user_role = payload['role']

        if user_role == "admin"
            user_id = params[:user_id]
            cancel_user_db = CancelUsers.find_by(user_id: user_id)
            if cancel_user_db.present?
                render json: {message: "It has already been canceled"}
            else
                cancel_user_create = CancelUsers.create(user_id: user_id)
            end
        else
            render json: {message: "Only admins!"}, status: 401
        end
        #erro quando passa no parâmetro user_id que não existe
        rescue ActiveRecord::InvalidForeignKey, SQLite3::ConstraintException => e
            render json: { error: "The user could not be canceled: #{e.message}" }, status: :unprocessable_entity
        end

    def unlockuser
        token = request.headers['Authorization']&.split(' ')&.last
        decoded_token = JWT.decode token, Rails.application.credentials.secret_hash_jwt, true, {algorithm: "HS256"}
        payload = decoded_token.first
        user_role = payload['role']

        if user_role == "admin"
            user_id = params[:user_id]
            cancel_user_db = CancelUsers.find_by(user_id: user_id)

            if cancel_user_db.present?
                cancel_user_db.destroy
                render json: {message: "Unlocked user"}
            else
                render json: {message: "User not found"}
            end
        else
            render json: {message: "Only admins!"}, status: 401
        end

    end

    private
    
    def user_params
        params
            .required(:user)
            .permit(:email, :password, :password_confirmation, :role)
    end

    def sign_in_params
        params
        .required(:login)
        .permit(:email, :password)
    end

    def not_authorized(e)
        render json: {message: "Nope!"}, status: 401
    end
end