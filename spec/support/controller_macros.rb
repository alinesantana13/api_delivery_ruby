module ControllerMacros
    def login_user
        @request.env["devise.mapping"] = Devise.mappings[:user]
        user = FactoryBot.build(:user)
        user
    end
end