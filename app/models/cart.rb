class Cart < ApplicationRecord
  ABANDONED_HOUR_LIMIT = 3.hours
  ABANDONED_DAY_LIMIT = 7.days

  has_many :cart_products, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :cart_products

  has_many :products, through: :cart_products

  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  validates_associated :cart_products

  after_touch :set_total_price
  after_touch :update_last_interaction_at

  def as_json(options = {})
    super(options).except('created_at', 'updated_at', 'last_interaction_at', 'abandoned_at')
                  .merge(products: products_and_quantities)
  end

  def set_total_price
    update(total_price: calculate_total_value)
  end

  def mark_as_abandoned
    return update(abandoned_at: nil) unless abandoned_hour_limit_exceded

    update(abandoned_at: Time.zone.now)
  end

  def remove_if_abandoned
    return unless abandoned? && abandoned_day_limit_exceded

    destroy
  end

  def abandoned?
    abandoned_at.present?
  end

  private

  def set_last_interaction_at
    self.set_last_interaction_at = Time.zone.now
  end

  def update_last_interaction_at
    update(last_interaction_at: updated_at)
  end

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

  def abandoned_hour_limit_exceded
    Time.zone.now - last_interaction_at > ABANDONED_HOUR_LIMIT
  end

  def abandoned_day_limit_exceded
    abandoned? && abandoned_at - last_interaction_at > ABANDONED_DAY_LIMIT
  end
end
