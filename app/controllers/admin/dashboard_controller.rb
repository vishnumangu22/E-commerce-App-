module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
      @total_revenue = Order.sum(:total_amount)
      @total_orders  = Order.count
      @total_users   = User.count
      @total_products = Product.count

      @low_stock_products = Product.where("stock <= ?", 5)

      @recent_orders = Order.order(created_at: :desc).limit(5)
      @recent_users  = User.order(created_at: :desc).limit(5)
    end
  end
end
