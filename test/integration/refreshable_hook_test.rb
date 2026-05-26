require "test_helper"
require "integration_tests_helper"

class RefreshableHookTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
    User.remove_instance_variable(:@otp_credentials_refresh) if User.instance_variable_defined?(:@otp_credentials_refresh)
  end

  test "sign-in succeeds when otp_credentials_refresh is disabled (false) on the model" do
    # Reproduces the upstream bug: `defined?(record.class.otp_credentials_refresh)`
    # is always truthy for OTP models, so the hook used to run
    # `Time.now + false` and raise TypeError on every sign-in.
    User.instance_variable_set(:@otp_credentials_refresh, false)

    create_full_user

    visit posts_path
    fill_in "user_email", with: "user@email.invalid"
    fill_in "user_password", with: "12345678"
    page.has_content?("Log in") ? click_button("Log in") : click_button("Sign in")

    assert_equal posts_path, current_path
  end

  test "sign-in succeeds when otp_credentials_refresh is disabled globally" do
    original = Devise.otp_credentials_refresh
    Devise.otp_credentials_refresh = false

    create_full_user

    visit posts_path
    fill_in "user_email", with: "user@email.invalid"
    fill_in "user_password", with: "12345678"
    page.has_content?("Log in") ? click_button("Log in") : click_button("Sign in")

    assert_equal posts_path, current_path
  ensure
    Devise.otp_credentials_refresh = original
  end
end
