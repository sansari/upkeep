require "test_helper"

class SuppliesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }
  test "GET /supplies renders list" do
    get supplies_path
    assert_response :success
    assert_select "h1", "Supplies"
  end

  test "GET /supplies.json returns supplies" do
    get supplies_path(format: :json)
    assert_response :success
    data = JSON.parse(response.body)
    assert data.is_a?(Array)
  end
end
