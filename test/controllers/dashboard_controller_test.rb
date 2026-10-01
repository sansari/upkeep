require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }
  test "GET / renders dashboard" do
    get root_path
    assert_response :success
    assert_select "h1", "Dashboard"
  end

  test "GET / renders Done button for each task" do
    get root_path
    assert_response :success
    assert_select "form[action*='/complete']" do |forms|
      assert forms.length > 0
    end
    assert_select "button", text: "Done"
  end

  test "GET / as JSON returns status data" do
    get root_path(format: :json)
    assert_response :success
    data = JSON.parse(response.body)
    assert data.key?("overdue")
    assert data.key?("due_soon")
    assert data.key?("low_stock_supplies")
  end
end
