class CartsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotDestroyed, with: :handle_record_invalid

  before_action :set_cart

  def create
    render json: @cart
  end

  def show
    render json: @cart
  end

  def add_item
    product_id = cart_params[:product_id]
    quantity = cart_params[:quantity].to_f

    cart_product = @cart.cart_products.find_or_create_by(product_id:)
    cart_product.quantity += quantity

    cart_product.destroy if cart_product.quantity <= 0

    if @cart.save!
      render json: @cart, status: :created
    end
  end

  def destroy
    product_id = cart_params[:product_id]
    cart_product = @cart.cart_products.find_by(product_id:)

    return handle_record_not_found if cart_product.nil?

    if cart_product.destroy!
      render json: @cart, status: :ok
    end
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def set_cart
    return @cart = Cart.find(session[:cart_id]) if session[:cart_id].present?

    @cart = Cart.create!
    session[:cart_id] = @cart.id
  end

  def handle_record_not_found
    render json: { error: 'Item not Found' }, status: :not_found
  end

  def handle_record_invalid(exception)
    render json: {
      error: 'Unprocessable Entity',
      message: exception.message,
      details: format_validation_errors(exception.try(:record))
    }, status: :unprocessable_entity
  end

  def format_validation_errors(record)
    record.errors.full_messages.map { |msg| { error: msg } }
  end
end
