class OrdersController < ApplicationController
  before_action :ensure_customer

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end


  def create
    cart = current_user.cart

    if cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty"
      return
    end

    ActiveRecord::Base.transaction do
      cart.cart_items.each do |item|
        if item.quantity > item.product.stock
          raise ActiveRecord::Rollback, "Insufficient stock"
        end
      end

      order = current_user.orders.create!(
        total_amount: cart.total_price,
        status: :pending
      )

      cart.cart_items.each do |item|
        order.order_items.create!(
          product: item.product,
          quantity: item.quantity,
          price: item.product.price
        )

        item.product.update!(
          stock: item.product.stock - item.quantity
        )
      end

      cart.cart_items.destroy_all
    end

    redirect_to root_path, notice: "Order placed successfully!"
  end


  private

  def ensure_customer
    redirect_to root_path, alert: "Admins cannot place orders" if current_user.admin?
  end
end
