class BadgeNotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.minutes, attempts: 3 do |_job, error|
    Rails.logger.error("BadgeNotificationJob failed after 3 attempts: #{error.message}")
    notify_failure(error)
  end

  def perform
    count = MaintenanceTask.overdue.count + MaintenanceTask.due_soon.count
    previous_count = Rails.cache.read("badge_notification_count")

    return if count == previous_count

    send_push_to_all(count: count, message: badge_message(count))
    Rails.cache.write("badge_notification_count", count)
  end

  private

  def badge_message(count)
    count > 0 ? "#{count} #{"task".pluralize(count)} need attention" : "All clear — nothing due!"
  end

  def self.notify_failure(error)
    vapid = Rails.application.credentials.vapid
    return unless vapid

    payload = { count: 1, message: "Badge job failed: #{error.message.truncate(100)}" }.to_json

    PushSubscription.find_each do |sub|
      WebPush.payload_send(
        message: payload,
        endpoint: sub.endpoint,
        p256dh: sub.p256dh,
        auth: sub.auth,
        vapid: {
          public_key: vapid[:public_key],
          private_key: vapid[:private_key],
          subject: vapid[:subject]
        }
      )
    rescue WebPush::Error
      # Can't do much if the failure notification also fails
    end
  rescue => e
    Rails.logger.error("Failed to send failure notification: #{e.message}")
  end

  def send_push_to_all(count:, message:)
    vapid = Rails.application.credentials.vapid
    return unless vapid

    payload = { count: count, message: message }.to_json

    PushSubscription.find_each do |sub|
      send_push(sub, payload, vapid)
    end
  end

  def send_push(subscription, payload, vapid)
    WebPush.payload_send(
      message: payload,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh,
      auth: subscription.auth,
      vapid: {
        public_key: vapid[:public_key],
        private_key: vapid[:private_key],
        subject: vapid[:subject]
      }
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    subscription.destroy
  rescue WebPush::ResponseError => e
    Rails.logger.warn("Push failed for subscription #{subscription.id}: #{e.message}")
  end
end
