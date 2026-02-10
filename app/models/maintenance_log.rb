class MaintenanceLog < ApplicationRecord
  belongs_to :maintenance_task

  validates :completed_at, presence: true

  default_scope { order(completed_at: :desc) }
end
