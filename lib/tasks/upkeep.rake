namespace :upkeep do
  desc "Show status of all maintenance tasks"
  task status: :environment do
    overdue = MaintenanceTask.overdue.by_urgency.includes(equipment: :area)
    due_soon = MaintenanceTask.due_soon.by_urgency.includes(equipment: :area)
    not_scheduled = MaintenanceTask.not_scheduled.includes(equipment: :area)
    low_stock = Supply.low_stock.includes(maintenance_task: { equipment: :area })

    if overdue.any?
      puts "\n🔴 OVERDUE (#{overdue.count})"
      puts "-" * 60
      overdue.each do |task|
        puts "  #{task.equipment.area.name} > #{task.equipment.name} > #{task.name}"
        puts "    Due: #{task.next_due_at.strftime('%b %d, %Y')} (#{task.overdue_by} overdue)"
      end
    end

    if due_soon.any?
      puts "\n🟡 DUE SOON (#{due_soon.count})"
      puts "-" * 60
      due_soon.each do |task|
        puts "  #{task.equipment.area.name} > #{task.equipment.name} > #{task.name}"
        puts "    Due: #{task.next_due_at.strftime('%b %d, %Y')}"
      end
    end

    if not_scheduled.any?
      puts "\n⚪ NOT SCHEDULED (#{not_scheduled.count})"
      puts "-" * 60
      not_scheduled.each do |task|
        puts "  #{task.equipment.area.name} > #{task.equipment.name} > #{task.name}"
        puts "    #{task.frequency_description} — never completed"
      end
    end

    if low_stock.any?
      puts "\n📦 LOW STOCK SUPPLIES (#{low_stock.count})"
      puts "-" * 60
      low_stock.each do |supply|
        task = supply.maintenance_task
        puts "  #{supply.name} (#{supply.quantity_on_hand}/#{supply.quantity_per_use} on hand)"
        puts "    For: #{task.equipment.area.name} > #{task.equipment.name} > #{task.name}"
        puts "    Buy: #{supply.purchase_url}" if supply.purchase_url.present?
      end
    end

    if overdue.empty? && due_soon.empty? && not_scheduled.empty? && low_stock.empty?
      puts "\n✅ Everything is up to date!"
    end

    puts ""
  end

  desc "Complete a maintenance task"
  task :complete_task, [:task_id] => :environment do |_t, args|
    task = MaintenanceTask.find(args[:task_id])
    print "Notes (optional): "
    notes = $stdin.gets&.chomp
    notes = nil if notes.blank?
    task.complete!(notes: notes)
    puts "✅ Completed: #{task.equipment.name} > #{task.name}"
    puts "   Next due: #{task.next_due_at.strftime('%b %d, %Y')}"
    task.supplies.each do |supply|
      status = supply.low_stock? ? " ⚠️  LOW STOCK" : ""
      puts "   #{supply.name}: #{supply.quantity_on_hand} remaining#{status}"
    end
  end

  desc "Add equipment to an area"
  task :add_equipment, [:area_name, :name] => :environment do |_t, args|
    area = Area.find_by!(name: args[:area_name])
    equipment = area.equipment.create!(name: args[:name])
    puts "✅ Added equipment: #{area.name} > #{equipment.name} (ID: #{equipment.id})"
  end

  desc "Add a maintenance task to equipment"
  task :add_task, [:equipment_id, :name, :freq_value, :freq_unit] => :environment do |_t, args|
    equipment = Equipment.find(args[:equipment_id])
    task = equipment.maintenance_tasks.create!(
      name: args[:name],
      frequency_value: args[:freq_value].to_i,
      frequency_unit: args[:freq_unit]
    )
    puts "✅ Added task: #{equipment.name} > #{task.name} (ID: #{task.id})"
    puts "   #{task.frequency_description}"
  end

  desc "Add a supply to a maintenance task"
  task :add_supply, [:task_id, :name, :purchase_url, :quantity] => :environment do |_t, args|
    task = MaintenanceTask.find(args[:task_id])
    supply = task.supplies.create!(
      name: args[:name],
      purchase_url: args[:purchase_url].presence,
      quantity_on_hand: (args[:quantity] || 0).to_i
    )
    puts "✅ Added supply: #{supply.name} (ID: #{supply.id})"
    puts "   For: #{task.equipment.name} > #{task.name}"
    puts "   On hand: #{supply.quantity_on_hand}"
  end

  desc "Update stock quantity for a supply"
  task :update_stock, [:supply_id, :quantity] => :environment do |_t, args|
    supply = Supply.find(args[:supply_id])
    supply.update!(quantity_on_hand: args[:quantity].to_i)
    puts "✅ Updated #{supply.name}: #{supply.quantity_on_hand} on hand"
  end
end
