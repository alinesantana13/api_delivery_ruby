class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :store
  belongs_to :user, foreign_key: :buyer_id
  has_many :order_items
  accepts_nested_attributes_for :order_items
  has_many :products, through: :order_items
  paginates_per 60
  validate :buyer_role

  # Enum for payment_status column
  enum :payment_status, [:paid_out, :in_the_delivery, :failed]

  state_machine initial: :created do
    state :created
    state :accepted
    state :preparing
    state :out_for_delivery
    state :delivered
    state :canceled

    event :accept do
      transition created: :accepted
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
