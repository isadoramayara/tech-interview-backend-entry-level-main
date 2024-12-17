class ChangeQuantityColumnTypeAndDefaultValue < ActiveRecord::Migration[7.1]
  def change
    change_column :cart_products, :quantity, :float, default: 0.0
  end
end
