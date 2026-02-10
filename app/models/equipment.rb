class Equipment < ApplicationRecord
  belongs_to :area
  has_many :maintenance_tasks, dependent: :destroy

  validates :name, presence: true

  scope :with_area, -> { includes(:area) }

  def status_summary
    tasks = maintenance_tasks
    {
      overdue: tasks.overdue.count,
      due_soon: tasks.due_soon.count,
      upcoming: tasks.upcoming.count
    }
  end
end
