class MaintenanceTaskImage < ApplicationRecord
  belongs_to :maintenance_task

  validates :image_path, presence: true, format: { with: %r{\A/guides/[a-z0-9/_-]+\.svg\z} }
  validates :alt_text, presence: true
  validates :position, numericality: { only_integer: true }
end
