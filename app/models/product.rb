class Product < ApplicationRecord
  belongs_to :store
  validates :title, presence: true
  validates :price, presence: true

end
