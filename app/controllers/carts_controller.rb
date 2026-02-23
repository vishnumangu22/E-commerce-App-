class CartsController < ApplicationController
  before_action :ensure_customer

  def show
    @cart = current_user.cart
  end


  private

  def ensure_customer
    redirect_to root_path, alert: "Admins cannot access cart" if current_user.admin?
  end
end
