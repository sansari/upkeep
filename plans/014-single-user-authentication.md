# Plan 014 — Single-User Authentication

## Context

Upkeep contains private household maintenance information but is currently readable by anyone who knows or discovers its Fly.io URL. The app needs a low-friction access boundary that works well when installed as a PWA on the owner's phone.

## Approach

- Add a password-only sign-in page backed by an `UPKEEP_PASSWORD` Fly secret; no user records or public registration.
- Protect every application controller route, including JSON and push-subscription endpoints.
- Keep the Fly health check and non-sensitive PWA manifest/service worker available without authentication.
- Store successful authentication in an encrypted, HTTP-only, same-site cookie that lasts one year and becomes invalid when the configured password changes.
- Rate-limit failed sign-in attempts and provide a visible sign-out action.
- Return `401 Unauthorized` for unauthenticated JSON requests and redirect browser requests to sign-in.

## Files Modified

- `app/controllers/application_controller.rb`
- `app/controllers/sessions_controller.rb`
- `app/views/layouts/application.html.erb`
- `app/views/layouts/authentication.html.erb`
- `app/views/sessions/new.html.erb`
- `config/routes.rb`
- `test/test_helper.rb`
- Controller authentication tests
- `SPEC.md`
- `CHANGELOG.md`
- `CLAUDE.md`

## Verification

- Run the full Rails test suite.
- Verify unauthenticated HTML redirects to sign-in and unauthenticated JSON returns `401`.
- Verify incorrect passwords are rejected and a correct password grants persistent access.
- Verify sign-out removes access.
- Verify the PWA manifest, service worker, and `/up` health endpoint remain reachable.
- Inspect the sign-in page and authenticated dashboard at mobile viewport size.
- Deploy with `UPKEEP_PASSWORD` configured as a Fly secret, then verify production health and authentication behavior.
