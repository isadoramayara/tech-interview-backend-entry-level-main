class AddStatusToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :integer
  end
end
