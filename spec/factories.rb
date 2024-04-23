FactoryBot.define do
    factory :user do
      email { "example@example.com" }
      password { "123456" }
      password_confirmation { "123456" }
      role {"seller"}
    end
end