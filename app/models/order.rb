class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :store
  belongs_to :user, foreign_key: :buyer_id
  has_many :order_items
  has_many :products, through: :order_items
  validate :buyer_role

  state_machine initial: :created do
    state :created
    state :ready_for_store
    state :accepted
    state :preparing
    state :out_for_delivery
    state :delivered
    state :canceled

    event :finished do
      transition created: :ready_for_store
    end

    event :accept do
      transition ready_for_store: :accepted
    end
    event :prepare do
      transition accepted: :preparing
    end
    event :start_delivery do
      transition preparing: :out_for_delivery
    end
    event :deliver do
      transition out_for_delivery: :delivered
    end

    event :cancel do
      transition [:created, :accepted] => :canceled
    end
  end

  private

  def buyer_role
    if !buyer.buyer?
      errors.add(:buyer, "should be a `user.buyer`")
    end
  end
end
