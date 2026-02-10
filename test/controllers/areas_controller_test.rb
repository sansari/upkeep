require "test_helper"

class AreasControllerTest < ActionDispatch::IntegrationTest
  test "GET /areas renders list" do
    get areas_path
    assert_response :success
    assert_select "h1", "Areas"
  end

  test "GET /areas/:id renders area detail" do
    get area_path(areas(:kitchen))
    assert_response :success
    assert_select "h1", /Kitchen/
  end

  test "GET /areas.json returns areas" do
    get areas_path(format: :json)
    assert_response :success
    data = JSON.parse(response.body)
    assert data.is_a?(Array)
  end
end
