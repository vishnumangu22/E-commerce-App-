class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  GST_RATE = 0.18

  # --------------------------
  # Subtotal
  # --------------------------
  def subtotal
    cart_items.includes(:product).sum do |item|
      item.product.price * item.quantity
    end
  end

  # --------------------------
  # GST Amount
  # --------------------------
  def gst
    (subtotal * GST_RATE).round(2)
  end

  # --------------------------
  # Grand Total
  # --------------------------
  def grand_total
    subtotal + gst
  end
end
