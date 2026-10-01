require "test_helper"

class EquipmentControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }
  test "GET /equipment/:id renders equipment detail" do
    get equipment_path(equipment(:water_filter))
    assert_response :success
    assert_select "h1", "Water Filter"
  end

  test "GET /equipment/:id.json returns equipment data" do
    get equipment_path(equipment(:water_filter), format: :json)
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "Water Filter", data["name"]
  end
end
