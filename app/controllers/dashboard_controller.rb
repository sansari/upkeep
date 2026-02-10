class DashboardController < ApplicationController
  def index
    @overdue_tasks = MaintenanceTask.overdue.by_urgency.includes(equipment: :area)
    @due_soon_tasks = MaintenanceTask.due_soon.by_urgency.includes(equipment: :area)
    actionable_task_ids = (@overdue_tasks + @due_soon_tasks).map(&:id)
    @low_stock_supplies = Supply.low_stock.where(maintenance_task_id: actionable_task_ids).includes(maintenance_task: { equipment: :area })
    @all_clear = @overdue_tasks.empty? && @due_soon_tasks.empty? && @low_stock_supplies.empty?

    respond_to do |format|
      format.html
      format.json do
        render json: {
          overdue: @overdue_tasks.as_json(include: { equipment: { include: :area } }),
          due_soon: @due_soon_tasks.as_json(include: { equipment: { include: :area } }),
          low_stock_supplies: @low_stock_supplies.as_json(include: { maintenance_task: { include: { equipment: { include: :area } } } })
        }
      end
    end
  end
end
