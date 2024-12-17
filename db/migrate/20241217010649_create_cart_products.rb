class CreateCartProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_products do |t|
      t.references :cart, null: false, foreign_key: { on_delete: :cascade }
      t.references :product, null: false, foreign_key: { on_delete: :cascade }
      t.decimal :quantity, precision: 17, scale: 2, default: 0.0
      t.decimal :total_price, precision: 17, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
