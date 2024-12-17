class CartProduct < ApplicationRecord
  belongs_to :cart, autosave: true, touch: true
  belongs_to :product, autosave: true
end