class CreateMaintenanceTaskImages < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_task_images do |t|
      t.references :maintenance_task, null: false, foreign_key: true
      t.string :image_path, null: false
      t.string :alt_text, null: false
      t.string :caption
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :maintenance_task_images, [ :maintenance_task_id, :position ]
  end
end
