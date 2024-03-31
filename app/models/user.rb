class User < ApplicationRecord
  enum :role, [:admin, :seller, :buyer]
  has_many :stores

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.from_token(token)
    nil
  end

  def self.token_for(user)
    payload = {id: user.id, email: user.email, role: user.role}
    JWT.encode payload, "muito.secreto", "HS256"
  end

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
