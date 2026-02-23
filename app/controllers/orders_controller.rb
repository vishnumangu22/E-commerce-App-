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
      # Calculate subtotal properly
      subtotal = cart.cart_items.sum do |item|
        item.product.price * item.quantity
      end

      order = current_user.orders.create!(
        total_amount: subtotal,
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


  def invoice
    @order = current_user.orders.find(params[:id])

    pdf = Prawn::Document.new

    # Header
    pdf.text "ShopApp Invoice", size: 24, style: :bold
    pdf.move_down 20

    pdf.text "Order ID: #{@order.id}"
    pdf.text "Date: #{@order.created_at.strftime('%d %B %Y')}"
    pdf.text "Customer: #{current_user.name}"
    pdf.move_down 20

    # Table Header
    table_data = [ [ "Product", "Quantity", "Unit Price", "Subtotal" ] ]

    @order.order_items.each do |item|
      subtotal = item.price * item.quantity

      table_data << [
        item.product.name,
        item.quantity,
        "Rs. #{item.price}",
        "Rs. #{subtotal}"
      ]
    end

    pdf.table(table_data, header: true)
    pdf.move_down 20

    pdf.text "Total Amount: Rs. #{@order.total_amount}",
             size: 16,
             style: :bold

    send_data pdf.render,
              filename: "invoice_order_#{@order.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def ensure_customer
    redirect_to root_path,
                alert: "Admins cannot place orders",
                status: :see_other if current_user.admin?
  end
end
