class User < ApplicationRecord
  class InvalidToken < StandardError; end

  enum :role, [:admin, :seller, :buyer]
  has_many :stores

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.from_token(token)
    decoded = JWT.decode token, Rails.application.credentials.secret_hash_jwt, true, {algorithm: "HS256"}
    user_data = decoded[0].with_indifferent_access
    User.find(user_data[:id])
  rescue  JWT::ExpiredSignature
    raise InvalidToken.new
  end

  def self.token_for(user)
    jwt_headers = {exp: 1.hours.from_now.to_i}
    payload = {id: user.id, email: user.email, role: user.role}
    JWT.encode payload.merge(jwt_headers), Rails.application.credentials.secret_hash_jwt, "HS256"
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
