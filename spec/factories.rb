FactoryBot.define do
  factory :credential do
    access { 1 }
    key { "MyString" }
  end

    factory :user do
      email { Faker::Internet.unique.email }
      password { "123456" }
      password_confirmation { "123456" }
      role { :seller }
    end
end