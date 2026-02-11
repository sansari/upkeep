require "test_helper"

class PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "create saves a new subscription" do
    assert_difference "PushSubscription.count", 1 do
      post push_subscriptions_url, params: {
        endpoint: "https://push.example.com/sub/new",
        keys: { p256dh: "new_key", auth: "new_auth" }
      }, as: :json
    end

    assert_response :created
  end

  test "create updates existing subscription by endpoint" do
    existing = push_subscriptions(:one)

    assert_no_difference "PushSubscription.count" do
      post push_subscriptions_url, params: {
        endpoint: existing.endpoint,
        keys: { p256dh: "updated_key", auth: "updated_auth" }
      }, as: :json
    end

    assert_response :created
    existing.reload
    assert_equal "updated_key", existing.p256dh
    assert_equal "updated_auth", existing.auth
  end

  test "destroy removes subscription" do
    existing = push_subscriptions(:one)

    assert_difference "PushSubscription.count", -1 do
      delete push_subscription_url(existing), params: {
        endpoint: existing.endpoint
      }, as: :json
    end

    assert_response :ok
  end

  test "destroy with unknown endpoint returns ok" do
    delete push_subscription_url(id: 0), params: {
      endpoint: "https://push.example.com/nonexistent"
    }, as: :json

    assert_response :ok
  end
end
