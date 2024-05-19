require 'faker'

FactoryBot.define do
  factory :order_item do
    
  end

  factory :order do
    
  end

  factory :credential do
    access { 1 }
    key { "MyString" }
  end

  factory :user do
    email { Faker::Internet.unique.email }
    password { "123456" }
    password_confirmation { "123456" }

    trait :admin do
      role { :admin }
    end

    trait :seller do
      role { :seller }
    end

    trait :buyer do
      role { :buyer }
    end
  end

  factory :store do
    name {Faker::Company.name}
    association :user, factory: :user, traits: [:seller]
  end
end