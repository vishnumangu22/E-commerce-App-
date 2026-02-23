class ProductsController < ApplicationController
  skip_before_action :require_user, only: [ :index, :show ]

  def index
    if params[:category_id].present?
      @products = Product.where(category_id: params[:category_id])
    else
      @products = Product.all
    end
  end

  def show
    @product = Product.find(params[:id])
  end
end
