class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def total_price
    cart_items.includes(:product).sum do |item|
      item.product.price * item.quantity
    end
  end
end
