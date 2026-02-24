class OrdersController < ApplicationController
  before_action :ensure_customer

  # ==============================
  # List Orders
  # ==============================
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  # ==============================
  # Show Order
  # ==============================
  def show
    @order = current_user.orders.find(params[:id])
  end

  # ==============================
  # Create Order (Checkout)
  # ==============================
  def create
    cart = current_user.cart

    if cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty"
      return
    end

    ActiveRecord::Base.transaction do
      # Calculate values BEFORE creating order
      subtotal = cart.subtotal
      gst = cart.gst
      grand_total = cart.grand_total

      order = current_user.orders.create!(
        total_amount: grand_total,   # store final amount
        status: :pending
      )

      cart.cart_items.each do |item|
        raise ActiveRecord::Rollback if item.quantity > item.product.stock

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


  # ==============================
  # Professional Invoice PDF
  # ==============================
  def invoice
    @order = current_user.orders.find(params[:id])

    pdf = Prawn::Document.new(page_size: "A4")

    # ------------------------------
    # Header
    # ------------------------------
    pdf.text "ShopApp", size: 28, style: :bold
    pdf.move_down 5
    pdf.text "INVOICE", size: 16, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # ------------------------------
    # Invoice Details
    # ------------------------------
    pdf.text "Invoice No: ##{@order.id}"
    pdf.text "Date: #{@order.created_at.strftime('%d %B %Y')}"
    pdf.move_down 10

    pdf.text "Billed To:", style: :bold
    pdf.text current_user.name
    pdf.text current_user.email
    pdf.move_down 20

    # ------------------------------
    # Table
    # ------------------------------
    table_data = [ [ "Product", "Qty", "Unit Price (Rs.)", "Subtotal (Rs.)" ] ]

    subtotal = 0

    @order.order_items.each do |item|
      line_total = item.price * item.quantity
      subtotal += line_total

      table_data << [
        item.product.name,
        item.quantity,
        item.price,
        line_total
      ]
    end

    pdf.table(table_data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = "EEEEEE"
      cells.padding = 8
    end

    pdf.move_down 20

    # ------------------------------
    # Totals Section
    # ------------------------------
    gst = (subtotal * 0.18).round(2)
    grand_total = subtotal + gst

    pdf.text "Subtotal: Rs. #{subtotal}", align: :right
    pdf.text "GST (18%): Rs. #{gst}", align: :right
    pdf.stroke_horizontal_rule
    pdf.move_down 5
    pdf.text "Grand Total: Rs. #{grand_total}",
             size: 16,
             style: :bold,
             align: :right

    pdf.move_down 30

    # ------------------------------
    # Footer
    # ------------------------------
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    pdf.text "Thank you for shopping with ShopApp!",
             size: 10,
             align: :center

    send_data pdf.render,
              filename: "invoice_#{@order.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def ensure_customer
    if current_user.admin?
      redirect_to root_path,
                  alert: "Admins cannot place orders",
                  status: :see_other
    end
  end
end
