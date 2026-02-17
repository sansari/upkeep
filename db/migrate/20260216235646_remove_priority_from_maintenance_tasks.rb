class RemovePriorityFromMaintenanceTasks < ActiveRecord::Migration[8.1]
  def change
    remove_column :maintenance_tasks, :priority, :string
  end
end
