class AddDefaultToTotalPriceAndPrice < ActiveRecord::Migration[7.1]
  def change
    change_column_default :carts, :total_price, 0.0
    change_column_default :products, :price, 0.0
  end
end
