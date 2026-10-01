require "test_helper"

class MaintenanceTasksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }
  test "GET /tasks/:id renders task detail" do
    get maintenance_task_path(maintenance_tasks(:replace_water_filter))
    assert_response :success
    assert_select "h1", /Replace filter/
  end

  test "POST /tasks/:id/complete marks task done and redirects" do
    task = maintenance_tasks(:replace_water_filter)
    assert_difference "MaintenanceLog.count", 1 do
      post complete_maintenance_task_path(task)
    end
    assert_redirected_to maintenance_task_path(task)
  end

  test "GET /tasks/:id renders Mark Done button" do
    get maintenance_task_path(maintenance_tasks(:replace_water_filter))
    assert_response :success
    assert_select "form[action=?]", complete_maintenance_task_path(maintenance_tasks(:replace_water_filter)) do
      assert_select "button", text: "Mark Done"
    end
  end

  test "POST /tasks/:id/complete redirects back to referrer" do
    task = maintenance_tasks(:replace_water_filter)
    post complete_maintenance_task_path(task), headers: { "HTTP_REFERER" => root_url }
    assert_redirected_to root_url
  end

  test "POST /tasks/:id/complete.json returns JSON" do
    task = maintenance_tasks(:replace_water_filter)
    post complete_maintenance_task_path(task, format: :json)
    assert_response :success
    data = JSON.parse(response.body)
    assert_not_nil data["last_completed_at"]
  end
end
