require 'rails_helper'

RSpec.describe "/cart", type: :request do
  require 'rails_helper'

  describe "POST /add_item" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_product) { CartProduct.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return({ cart_id: cart.id })

        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_product.reload.quantity }.by(2)
      end
    end
  end
end
