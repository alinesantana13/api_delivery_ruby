class Product < ApplicationRecord
  has_one_attached :image
  belongs_to :store
  has_many :orders, through: :order_items
  paginates_per 10

  validates :title, presence: true
  validates :price, presence: true

  # Discard inclusion
  include Discard::Model

end
