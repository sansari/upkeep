class CreateMaintenanceLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_logs do |t|
      t.references :maintenance_task, null: false, foreign_key: true
      t.datetime :completed_at, null: false
      t.text :notes

      t.timestamps
    end
  end
end
