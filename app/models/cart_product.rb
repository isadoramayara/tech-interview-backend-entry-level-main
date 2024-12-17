class CartProduct < ApplicationRecord
  belongs_to :cart, autosave: true, touch: true
  belongs_to :product, autosave: true

  validates :cart, :product, presence: true
  validates_numericality_of :quantity, greater_than_or_equal_to: 0
end