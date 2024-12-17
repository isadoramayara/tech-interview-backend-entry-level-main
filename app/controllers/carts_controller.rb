class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: @cart
  end

  def update
    product_id = cart_params[:product_id]
    quantity = cart_params[:quantity]

    cart_product = @cart.cart_products.find_or_create_by(product_id:)
    cart_product.quantity = quantity

    if cart_product.save
      render json: @cart, status: :created
    else
      render json: @cart, include: @cart.errors, status: :unprocessable_entity
    end
  end

  def destroy
    product_id = cart_params[:product_id]
    cart_product = @cart.cart_products.find_by(product_id:)

    if cart_product.destroy
      render json: @cart, status: :ok
    else
      render json: { cart: @cart, errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def set_cart
    return @cart = Cart.find(session[:cart_id]) if session[:cart_id].present?

    @cart = Cart.create!(status: :open, total_price: 0.0)
    session[:cart_id] = @cart.id
  end
end
