require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  let(:product) { create(:product, name: "Test Product", price: 10.0) }
  let(:cart) { Cart.create }

  before do
    session[:cart_id] = cart.id
  end

  describe "GET #show" do
    it "returns the current cart" do
      get :show
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(cart.id)
    end
  end

  describe "POST #create" do
    it "creates a cart and returns it" do
      session[:cart_id] = nil
      post :create
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("id")
    end
  end

  describe "POST #add_item" do
    let!(:cart_product) { CartProduct.create(cart: cart, product: product, quantity: 1)}

    context "when adding a valid product" do
      it "adds the product to the cart" do
        post :add_item, params: { product_id: product.id, quantity: 2 }
        expect(response).to have_http_status(:ok)
        cart.reload
        expect(cart.cart_products.count).to eq(1)
        expect(cart.cart_products.first.quantity).to eq(3.0)
      end
    end

    context "when adding a product with negative quantity resulting in removal" do
      it "removes the product from the cart" do
        post :add_item, params: { product_id: product.id, quantity: -1 }
        expect(response).to have_http_status(:ok)
        cart.reload
        expect(cart.cart_products.count).to eq(0)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when the product exists in the cart" do
      let!(:cart_product) { CartProduct.create(cart: cart, product: product, quantity: 1)}

      before { cart.cart_products << cart_product }

      it "removes the product from the cart" do
        delete :destroy, params: { product_id: product.id }
        expect(response).to have_http_status(:ok)
        cart.reload
        expect(cart.cart_products.count).to eq(0)
      end
    end

    context "when the product does not exist in the cart" do
      it "returns a 404 error" do
        delete :destroy, params: { product_id: product.id }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Item not Found")
      end
    end
  end
end
