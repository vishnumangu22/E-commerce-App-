class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum :status, { pending: 0, completed: 1, cancelled: 2 }

  def total_amount
    order_items.sum { |item| item.price * item.quantity }
  end
end
