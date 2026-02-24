class WishlistsController < ApplicationController
  before_action :require_user
  before_action :ensure_customer

  def index
    @wishlist_items = current_user.wishlists.includes(:product)
  end

  def create
    product = Product.find(params[:product_id])

    unless current_user.wishlists.exists?(product_id: product.id)
      current_user.wishlists.create(product: product)
    end

    redirect_back fallback_location: root_path,
                  notice: "Added to wishlist"
  end
  def destroy
    wishlist = current_user.wishlists.find(params[:id])
    wishlist.destroy

    redirect_back fallback_location: root_path,
                  notice: "Removed from wishlist"
  end

  private

  def ensure_customer
    redirect_to root_path, alert: "Admins cannot use wishlist" if current_user.admin?
  end
end
