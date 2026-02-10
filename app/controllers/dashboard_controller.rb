class DashboardController < ApplicationController
  def index
    @overdue_tasks = MaintenanceTask.overdue.by_urgency.includes(equipment: :area)
    @due_soon_tasks = MaintenanceTask.due_soon.by_urgency.includes(equipment: :area)
    @not_scheduled_tasks = MaintenanceTask.not_scheduled.includes(equipment: :area)
    @low_stock_supplies = Supply.low_stock.includes(maintenance_task: { equipment: :area })

    respond_to do |format|
      format.html
      format.json do
        render json: {
          overdue: @overdue_tasks.as_json(include: { equipment: { include: :area } }),
          due_soon: @due_soon_tasks.as_json(include: { equipment: { include: :area } }),
          not_scheduled: @not_scheduled_tasks.as_json(include: { equipment: { include: :area } }),
          low_stock_supplies: @low_stock_supplies.as_json(include: { maintenance_task: { include: { equipment: { include: :area } } } })
        }
      end
    end
  end
end
