require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated HTML requests redirect to sign in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "unauthenticated JSON requests return unauthorized" do
    get root_path(format: :json)

    assert_response :unauthorized
  end

  test "correct password signs in and returns to requested page" do
    get areas_path
    post session_path, params: { password: ENV.fetch("UPKEEP_PASSWORD") }

    assert_redirected_to areas_path
    authentication_cookie = response.headers["Set-Cookie"].find { |cookie| cookie.start_with?("upkeep_authentication=") }
    assert authentication_cookie
    assert_includes authentication_cookie, "expires="
    assert_includes authentication_cookie, "httponly"
    assert_includes authentication_cookie, "samesite=lax"

    get areas_path
    assert_response :success
  end

  test "incorrect password is rejected" do
    post session_path, params: { password: "incorrect" }

    assert_response :unprocessable_entity
    assert_select "[role='alert']", text: /incorrect/

    get root_path
    assert_redirected_to new_session_path
  end

  test "sign out removes authenticated access" do
    sign_in
    delete session_path

    assert_redirected_to new_session_path

    get root_path
    assert_redirected_to new_session_path
  end

  test "authenticated users are redirected away from sign in" do
    sign_in
    get new_session_path

    assert_redirected_to root_path
  end

  test "PWA assets and health check remain public" do
    get pwa_manifest_path(format: :json)
    assert_response :success

    get pwa_service_worker_path
    assert_response :success

    get rails_health_check_path
    assert_response :success
  end
end
