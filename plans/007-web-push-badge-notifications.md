# Plan 007: Web Push Badge Notifications

## Context

The PWA badge (plan 005) only updates while the app is open — the Stimulus controller polls every 5 minutes and calls `navigator.setAppBadge()`. When the app is closed or backgrounded on iOS, the badge goes stale. Web Push (iOS 16.4+) allows a server-side job to send push notifications that update the badge in the background.

## Approach

- Add `web-push` gem with VAPID authentication
- Client subscribes to push after granting notification permission
- Server stores push subscriptions in a new `PushSubscription` model
- A recurring Solid Queue job (every 12 hours) checks task counts and sends a push when the count changes
- Service worker receives the push, shows a notification, and updates the badge
- Job self-reports failures via push notification (retries 3 times first)

## Files Modified/Created

| File | Action |
|------|--------|
| `Gemfile` | Added `web-push` gem |
| `db/migrate/20260211001244_create_push_subscriptions.rb` | New — migration |
| `app/models/push_subscription.rb` | New — model with validations |
| `app/controllers/push_subscriptions_controller.rb` | New — create/destroy endpoints |
| `config/routes.rb` | Added push_subscriptions routes |
| `app/jobs/badge_notification_job.rb` | New — recurring job with retry + failure notification |
| `config/recurring.yml` | Added badge_notification schedule (every 12 hours) |
| `app/javascript/controllers/badge_controller.js` | Added push subscription after permission grant |
| `app/views/pwa/service-worker.js` | Added push + notificationclick handlers |
| `app/views/layouts/application.html.erb` | Added VAPID public key data attribute |
| `config/credentials.yml.enc` | Added VAPID keys |
| `test/models/push_subscription_test.rb` | New — model tests |
| `test/jobs/badge_notification_job_test.rb` | New — job tests |
| `test/controllers/push_subscriptions_controller_test.rb` | New — controller tests |
| `test/fixtures/push_subscriptions.yml` | New — test fixtures |

## Verification

1. Run `bin/rails test` — all tests pass
2. Open app in browser, grant notification permission → subscription saved to DB
3. Deploy to Railway, open PWA on iPhone, grant permission, close app → badge updates on next job run
4. Job failure sends push notification to all subscribers
