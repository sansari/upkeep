class Area < ApplicationRecord
  has_many :equipment, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  default_scope { order(:position, :name) }

  def overdue_tasks_count
    MaintenanceTask.joins(:equipment).where(equipment: { area_id: id }).overdue.count
  end

  def due_soon_tasks_count
    MaintenanceTask.joins(:equipment).where(equipment: { area_id: id }).due_soon.count
  end

  def tasks_count
    MaintenanceTask.joins(:equipment).where(equipment: { area_id: id }).count
  end
end
