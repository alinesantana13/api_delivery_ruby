class User < ApplicationRecord
  enum :role, [:admin, :seller, :buyer]
  has_many :stores

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def admin?
    return role == "admin"
  end

  def seller?
    role == "seller"
  end

  def buyer?
    role == "buyer"
  end

end
