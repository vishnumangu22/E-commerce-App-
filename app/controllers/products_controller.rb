class ProductsController < ApplicationController
  skip_before_action :require_user, only: [ :index, :show ]

  def index
    @categories = Category.all
    @products = Product.includes(:category)

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    @wishlist_product_ids = current_user&.wishlists&.pluck(:product_id) || []
  end

  def show
    @product = Product.includes(:category).find(params[:id])

    if current_user
      @wishlist_item = current_user.wishlists.find_by(product_id: @product.id)
    end
  end
end
