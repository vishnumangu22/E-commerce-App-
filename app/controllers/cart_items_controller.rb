class CartItemsController < ApplicationController
  before_action :ensure_customer

  def create
    @cart = current_user.cart
    product = Product.find(params[:product_id])

    cart_item = @cart.cart_items.find_by(product_id: product.id)

    if product.stock <= 0
      redirect_back fallback_location: root_path,
                    alert: "Product is out of stock",
                    status: :see_other
      return
    end

    if cart_item
      if cart_item.quantity < product.stock
        cart_item.increment!(:quantity)
      else
        redirect_back fallback_location: root_path,
                      alert: "Not enough stock available",
                      status: :see_other
        return
      end
    else
      @cart.cart_items.create(product: product, quantity: 1)
    end

    redirect_back fallback_location: root_path,
                  notice: "Product added to cart",
                  status: :see_other
  end

  def update
    cart_item = current_user.cart.cart_items.find(params[:id])

    if params[:type] == "increase"
      if cart_item.quantity < cart_item.product.stock
        cart_item.increment!(:quantity)
      end

    elsif params[:type] == "decrease"
      if cart_item.quantity > 1
        cart_item.decrement!(:quantity)
      else
        cart_item.destroy
        redirect_to cart_path,
                    notice: "Item removed",
                    status: :see_other
        return
      end
    end

    redirect_to cart_path, status: :see_other
  end

  def destroy
    cart_item = current_user.cart.cart_items.find(params[:id])
    cart_item.destroy

    redirect_to cart_path,
                notice: "Item removed",
                status: :see_other
  end

  private

  def ensure_customer
    redirect_to root_path,
                alert: "Admins cannot modify cart",
                status: :see_other if current_user.admin?
  end
end
