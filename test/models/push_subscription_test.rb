require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  test "valid subscription" do
    sub = PushSubscription.new(
      endpoint: "https://push.example.com/sub/new",
      p256dh: "key123",
      auth: "auth123"
    )
    assert sub.valid?
  end

  test "requires endpoint" do
    sub = PushSubscription.new(p256dh: "key", auth: "auth")
    assert_not sub.valid?
    assert_includes sub.errors[:endpoint], "can't be blank"
  end

  test "requires p256dh" do
    sub = PushSubscription.new(endpoint: "https://push.example.com/new", auth: "auth")
    assert_not sub.valid?
    assert_includes sub.errors[:p256dh], "can't be blank"
  end

  test "requires auth" do
    sub = PushSubscription.new(endpoint: "https://push.example.com/new", p256dh: "key")
    assert_not sub.valid?
    assert_includes sub.errors[:auth], "can't be blank"
  end

  test "endpoint must be unique" do
    existing = push_subscriptions(:one)
    sub = PushSubscription.new(
      endpoint: existing.endpoint,
      p256dh: "different_key",
      auth: "different_auth"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:endpoint], "has already been taken"
  end
end
