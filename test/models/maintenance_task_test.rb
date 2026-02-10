require "test_helper"

class MaintenanceTaskTest < ActiveSupport::TestCase
  test "overdue scope returns tasks past due" do
    overdue = MaintenanceTask.overdue
    assert_includes overdue, maintenance_tasks(:replace_water_filter)
    assert_not_includes overdue, maintenance_tasks(:replace_shower_filter)
  end

  test "due_soon scope returns tasks due within 7 days" do
    # replace_shower_filter is 10 days out, so not due_soon
    due_soon = MaintenanceTask.due_soon
    assert_not_includes due_soon, maintenance_tasks(:replace_shower_filter)
  end

  test "not_scheduled scope returns tasks with no next_due_at" do
    not_scheduled = MaintenanceTask.not_scheduled
    assert_includes not_scheduled, maintenance_tasks(:wash_shower_head)
  end

  test "due_status returns correct status" do
    assert_equal :overdue, maintenance_tasks(:replace_water_filter).due_status
    assert_equal :upcoming, maintenance_tasks(:replace_shower_filter).due_status
    assert_equal :not_scheduled, maintenance_tasks(:wash_shower_head).due_status
  end

  test "complete! logs completion and recalculates due date" do
    task = maintenance_tasks(:replace_water_filter)
    assert_difference "MaintenanceLog.count", 1 do
      task.complete!(notes: "Done")
    end
    task.reload
    assert_not_nil task.last_completed_at
    assert task.next_due_at > Time.current
    assert_equal "Done", task.maintenance_logs.first.notes
  end

  test "complete! decrements supplies" do
    task = maintenance_tasks(:replace_shower_filter)
    supply = supplies(:shower_carbon_filter)
    assert_equal 2, supply.quantity_on_hand

    task.complete!
    supply.reload
    assert_equal 1, supply.quantity_on_hand
  end

  test "frequency_description returns human-readable string" do
    task = maintenance_tasks(:replace_water_filter)
    assert_equal "Every 12 months", task.frequency_description
  end

  test "validates frequency_unit inclusion" do
    task = maintenance_tasks(:replace_water_filter)
    task.frequency_unit = "centuries"
    assert_not task.valid?
  end

  test "validates priority inclusion" do
    task = maintenance_tasks(:replace_water_filter)
    task.priority = "extreme"
    assert_not task.valid?
  end
end
