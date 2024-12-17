class ChangeForeignKeyForCartProducts < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :cart_products, :carts
    add_foreign_key :cart_products, :carts, on_delete: :cascade

    remove_foreign_key :cart_products, :products
    add_foreign_key :cart_products, :products, on_delete: :cascade
  end
end
