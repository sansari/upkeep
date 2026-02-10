class Supply < ApplicationRecord
  belongs_to :maintenance_task

  has_one :equipment, through: :maintenance_task
  has_one :area, through: :equipment

  validates :name, presence: true
  validates :quantity_on_hand, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity_per_use, numericality: { greater_than: 0 }

  scope :low_stock, -> { where("quantity_on_hand < quantity_per_use") }

  def low_stock?
    quantity_on_hand < quantity_per_use
  end

  def decrement_stock!
    update!(quantity_on_hand: [quantity_on_hand - quantity_per_use, 0].max)
  end
end
