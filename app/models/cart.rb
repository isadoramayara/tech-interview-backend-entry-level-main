class Cart < ApplicationRecord
  scope :inactive_for, lambda { |hours_ago| where('updated_at > ?', hours_ago)  }
  scope :abandoned_for, lambda { |days_ago| where(status: :abandoned).where('updated_at < ?', days_ago) }

  has_many :cart_products, autosave: true, dependent: :destroy
  has_many :products, through: :cart_products

  enum status: [:open, :abandoned]

  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  validates_associated :cart_products

  after_touch :set_total_price

  def set_total_price
    update(total_price: calculate_total_value)
  end

  def as_json(options = {})
    super(options).merge(products: products_and_quantities)
  end

  private

  def calculate_total_value
    return 0.0 if products.blank?

    product_prices_multiplied_by_quantity.sum
  end

  def products_and_quantities
    cart_products.includes(:product).map do |cart_product|
      {
        id: cart_product.product.id,
        name: cart_product.product.name,
        price: cart_product.product.price,
        quantity: cart_product.quantity
      }
    end
  end

  def product_prices_multiplied_by_quantity
    self.cart_products.flat_map do |cart_product|
      product = cart_product.product

      product_price = product.price
      quantity = cart_product.quantity

      [product_price.to_f * quantity.to_f]
    end
  end
end
