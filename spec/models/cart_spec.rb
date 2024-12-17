require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end

    it 'validates numericality of total_price with valid values' do
      cart = described_class.new(total_price: 0)
      expect(cart.valid?).to be_truthy

      cart.total_price = 100
      expect(cart.valid?).to be_truthy
    end
  end

  describe 'set_total_price' do
    it 'calculates total_price based on cart_products' do
      product1 = create(:product, price: 10)
      product2 = create(:product, price: 20)
      cart = create(:shopping_cart)
      cart.cart_products.create(product: product1, quantity: 2)
      cart.cart_products.create(product: product2, quantity: 3)

      expect(cart.total_price).to eq(10 * 2 + 20 * 3)
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end

    it 'does not mark cart as abandoned if hour limit is not exceeded' do
      shopping_cart.update(last_interaction_at: 1.hour.ago)
      expect { shopping_cart.mark_as_abandoned }.not_to change { shopping_cart.abandoned_at }
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end

    it 'does not remove the shopping cart if not abandoned long enough' do
      shopping_cart.update(last_interaction_at: 3.days.ago)
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.not_to change { Cart.count }
    end
  end
end
