class Store < ApplicationRecord
    belongs_to :user
    before_validation :ensure_seller
    validates :name, presence: true, length: {minimum: 3}
    has_many :products
    paginates_per 6

    private

    def ensure_seller
        self.user = nil if self.user && !self.user.seller?
    end
end
