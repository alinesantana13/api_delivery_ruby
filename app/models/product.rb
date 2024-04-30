class Product < ApplicationRecord
  belongs_to :store
  has_many :orders, through: :order_items

  validates :title, presence: true
  validates :price, presence: true

end
