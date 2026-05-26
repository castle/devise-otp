# Changelog

## 2.0.0.castle.2 (Castle fork)

- Drop the dead `app.config.assets.precompile << "devise-otp.js"`
  registration (and the now-unused
  `config.devise_otp.precompile_assets` opt-out) from the engine.
  Upstream 2.0.0 stopped shipping any JavaScript (the QR code is now
  rendered server-side as an inline SVG via `rqrcode` in
  `otp_authenticator_token_image`), so the precompile entry pointed at
  a file that no longer exists and would raise
  `Sprockets::FileNotFound` during asset precompile in any app that
  uses Sprockets/Propshaft and inherits this registration. Apps that
  want the gem's `app/assets/stylesheets/devise-otp.css` precompiled
  can still add it to their own `assets.precompile` list — nothing was
  auto-registering the CSS before either.

## 2.0.0.castle.1 (Castle fork)

- Fix `Refreshable` hook raising `TypeError` on every sign-in when
  `otp_credentials_refresh` is set to `false`. Upstream guarded on
  `defined?(record.class.otp_credentials_refresh)`, which is always
  truthy for any model that includes `:otp_authenticatable`
  (`Devise::Models.config` defines the accessor on the class). Switched
  to a truthy-value check so disabled refresh settings short-circuit
  the assignment instead of attempting `Time.now + false`.
- Add `Devise.otp_challenge_via_strategy` config option (default
  `true`, preserving the upstream 2.0.0 behaviour). Setting it to
  `false` makes `Devise::Strategies::DatabaseAuthenticatable` succeed
  without redirecting to the OTP challenge, so applications that need
  to run additional logic between authentication and the OTP redirect
  (e.g. a risk check that decides which OTP flow to use) can drive the
  challenge from a controller instead of the Warden strategy. This
  mirrors the pre-2.0.0 flow.

## 2.0.0.castle.0 (Castle fork)

This is the initial release of Castle's fork of `wmlele/devise-otp`,
tracking upstream `master` (post-`v2.0.0`, includes Devise 5 support,
Rails 8.1 support, Ruby 4 in CI matrix).

Castle-only changes on top of upstream `master`:

- Pin Ruby 3.3.10 via `.tool-versions` to align with Castle's `web`
  app.
- Drop the `standardrb` placeholder gem from `Gemfile` and
  `gemfiles/rails_*.gemfile` — it's an inoperative placeholder per
  its own install-time warning, and nothing in the source tree
  references it.
- Drop the `appraisal` dev dependency, `bin/appraisal`, and the
  `Appraisals` DSL file. CI invokes `gemfiles/rails_*.gemfile`
  directly via `BUNDLE_GEMFILE`, so the regenerator was unused
  outside of dev workflows. Per-Rails gemfiles are now
  hand-maintained (same approach as `castle_devise`).
- Add fork notice to `README.md`.
- Bump `VERSION` to `2.0.0.castle.0`.

This fork's `2.0.0.castle` branch should be re-synced whenever
upstream cuts a release that covers our deltas.

## v2.0.0

Bug fixes:
- Fixed an issue where Turbo/Hotwire enabled applications return a JS error for failed OTP authentication;
- Fixed an issue with the "Remember me" functionality for users with OTP enabled;

Improvements:
- Add support for Lockable strategy to OTP credentials form;
- Use locales for "Enabled/Disabled" status;
- Fix spelling, spacing, and grammatical issues in the default locales file;

Code Quality:
- Use built-in functionality from rotp gem for handling the TOTP drift window;
- Use standard URL Helpers in database\_authenticatable;
- Refactor code for otp\_issuer method;
- Cleanup Ruby syntax in ERB views;
- Add Timecop for testing time based functionality;
- Add Rubocop and ERB Lint;

Maintenance
- Bump rqrcode to 3.0.0

Breaking changes
- Move browser persistence actions to dedicated controller
- Standardize browser persistence routes, and use buttons for controls

### Upgrading

If you have customized the otp_tokens controller/views, or the locales file for browser persistence:
1. Regenerate the "otp_tokens" controller and views

```
rails g devise_otp:controllers
rails g devise_otp:views
```

2. Reapply any desired changes
- Note that the browser persistence controls now use "button_to", rather than "link_to"

3. Update your locales file
- Move any \*\_persistence keys from devise.otp.otp_tokens/ to devise.otp.otp_persistence/


## 1.1.0

Bug fixes:
- Update refreshable hook to ensure that user models without Devise OTP can still sign in
- Add tests for non-OTP user models to confirm resolution

Improvements:
- Remove references to MongoDB from test suite
- Standardize test application's database configuration
- Add Development Instructions to README

## 1.0.1
- Add support for Ruby 3.4
- Set minimum Ruby version to 3.2
- Set miminum Rails version to 7.1
- Add MIT license type to gemspec
- Correct Devise spelling error in README

## 1.0.0
- Add support for Rails 8
- Generate QR Codes as SVG
- Fix Issue with Invalid Token Message
- Simplify OTP Credentials Controller
- Expand Flash Message Tests
- Use Appraisal gem to against older Rails versions

## 0.8.0
- Add support for Rails 7.2 and drop support for Rails 6.1
- Fix issue with scoped redirects for non-default resources
- Add migration version numbers
- Cleanup old docs

## 0.7.1
- Fix host and port for 3rd-party tests

## 0.7.0

Breaking changes:

- Require confirmation token before enabling Two Factor Authentication (2FA) to ensure that user has added OTP token properly to their device
- Update DeviseAuthenticatable to redirect user (rather than login user) when OTP is enabled
- Remove OtpAuthenticatable callbacks for setting OTP credentials on create action (no longer needed)
- Replace OtpAuthenticatable "reset_otp_credentials" methods with "clear_otp_fields!" method
- Update otp_tokens#edit to populate OTP secrets (rather than assuming they are populated via callbacks in OTPDeviseAuthenticatable module)
- Repurpose otp_tokens#destroy to disable 2FA and clear OTP secrets (rather than resetting them)
- Add reset token action and hide/repurpose disable token action
- Update disable action to preserve the existing token secret
- Hide button for mandatory OTP
- Add Refreshable hook, and tie into after\_set\_user calback
- Utilize native warden session for scoping of credentials\_refreshed\_at and refresh\_return\_url properties
- Require adding "ensure\_mandatory\_{scope}\_otp! to controllers for mandatory OTP
- Update locales to support the new workflow

### Upgrading

Regenerate your views with `rails g devise_otp:views` and update locales.

Changes to locales:

- Remove:
  - otp_tokens.enable_request
  - otp_tokens.status
  - otp_tokens.submit
- Add to otp_tokens scope:
  - enable_link
- Move/rename devise.otp.token_secret.reset_\* values to devise.otp.otp_tokens.disable_\* (for consistency with "enable_link")
  - disable_link
  - disable_explain
  - disable_explain_warn
- Add to new edit_otp_token scope:
  - title
  - lead_in
  - step1
  - step2
  - confirmation_code
  - submit
- Move "explain" to new edit_otp_token scope
- Add devise.otp.otp_tokens.could_not_confirm
- Rename "successfully_reset_creds" to "successfully_disabled_otp"

You can grab the full locale file [here](https://github.com/wmlele/devise-otp/blob/master/config/locales/en.yml).

## 0.6.0

Improvements:

- support rails 6.1 by @cotcomsol in #67

Fixes:

- mandatory otp fix by @cotcomsol in #68
- remove success message by @strzibny in #69
