class MaintenanceTask < ApplicationRecord
  belongs_to :equipment
  has_many :maintenance_logs, dependent: :destroy
  has_many :supplies, dependent: :destroy
  has_many :instruction_images, -> { order(:position, :id) }, class_name: "MaintenanceTaskImage", dependent: :destroy

  has_one :area, through: :equipment

  validates :name, presence: true
  validates :frequency_value, presence: true, numericality: { greater_than: 0 }
  validates :frequency_unit, presence: true, inclusion: { in: %w[days weeks months years] }

  scope :overdue, -> { where("next_due_at < ?", Time.current) }
  scope :due_soon, -> { where(next_due_at: Time.current..14.days.from_now) }
  scope :upcoming, -> { where("next_due_at > ?", 14.days.from_now) }
  scope :not_scheduled, -> { where(next_due_at: nil) }
  scope :by_urgency, -> { order(Arel.sql("CASE WHEN next_due_at IS NULL THEN 1 ELSE 0 END, next_due_at ASC")) }

  def complete!(notes: nil)
    transaction do
      maintenance_logs.create!(completed_at: Time.current, notes: notes)
      update!(
        last_completed_at: Time.current,
        next_due_at: Time.current + frequency_value.send(frequency_unit)
      )
      supplies.each(&:decrement_stock!)
    end
  end

  def due_status
    return :not_scheduled if next_due_at.nil?
    return :overdue if next_due_at < Time.current
    return :due_soon if next_due_at <= 14.days.from_now
    :upcoming
  end

  def frequency_description
    unit = frequency_value == 1 ? frequency_unit.singularize : frequency_unit
    "Every #{frequency_value} #{unit}"
  end

  def overdue_by
    return nil unless due_status == :overdue
    days = (Time.current.to_date - next_due_at.to_date).to_i
    if days < 7
      "#{days} #{"day".pluralize(days)}"
    elsif days < 30
      weeks = days / 7
      "#{weeks} #{"week".pluralize(weeks)}"
    else
      months = days / 30
      "#{months} #{"month".pluralize(months)}"
    end
  end
end
