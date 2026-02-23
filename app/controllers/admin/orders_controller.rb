module Admin
  class OrdersController < ApplicationController
    before_action :require_admin

    def index
      @orders = Order.includes(:user).order(created_at: :desc)
    end

    def show
      @order = Order.find(params[:id])
    end

    def update
      @order = Order.find(params[:id])

      if @order.update(status: params[:order][:status])
        redirect_to admin_orders_path, notice: "Order status updated"
      else
        redirect_to admin_orders_path, alert: "Update failed"
      end
    end
  end
end
