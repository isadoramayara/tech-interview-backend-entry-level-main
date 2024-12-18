class RemoveDefaultFromPrice < ActiveRecord::Migration[7.1]
  def change
    change_column_default :products, :price, from: "0.0", to: nil
  end
end
