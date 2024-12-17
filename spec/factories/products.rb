FactoryBot.define do
  factory :product, class: 'Product' do
    name { 'Test Product' }
    price { 0.0 }
  end
end