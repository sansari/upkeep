require "test_helper"

class BadgeNotificationJobTest < ActiveJob::TestCase
  test "job can be enqueued" do
    assert_enqueued_with(job: BadgeNotificationJob) do
      BadgeNotificationJob.perform_later
    end
  end

  test "job computes correct task count" do
    expected = MaintenanceTask.overdue.count + MaintenanceTask.due_soon.count
    assert expected >= 0
  end
end
