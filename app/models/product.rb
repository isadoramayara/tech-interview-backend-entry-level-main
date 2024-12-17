class Product < ApplicationRecord
  has_many :cart_products, dependent: :destroy
  has_many :carts, through: :cart_products

  validates_presence_of :name, :price
  validates_numericality_of :price, greater_than_or_equal_to: 0

  def quantity(cart)
    cart_product = cart_products.find_by(cart:)

    cart_product.quantity
  end
end
