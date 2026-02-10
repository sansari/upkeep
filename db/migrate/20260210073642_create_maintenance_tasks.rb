class CreateMaintenanceTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_tasks do |t|
      t.references :equipment, null: false, foreign_key: true
      t.string :name, null: false
      t.text :instructions
      t.integer :frequency_value, null: false
      t.string :frequency_unit, null: false
      t.datetime :last_completed_at
      t.datetime :next_due_at
      t.string :priority, default: "medium", null: false
      t.text :notes

      t.timestamps
    end

    add_index :maintenance_tasks, :next_due_at
    add_index :maintenance_tasks, :priority
  end
end
