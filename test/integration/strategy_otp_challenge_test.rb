require "test_helper"
require "integration_tests_helper"

class StrategyOtpChallengeTest < ActionDispatch::IntegrationTest
  def teardown
    Capybara.reset_sessions!
    Devise.otp_challenge_via_strategy = true
  end

  test "by default, the strategy redirects to otp_credential when the user has OTP enabled" do
    enable_otp_and_sign_in
    assert_equal user_otp_credential_path, current_path
  end

  test "with otp_challenge_via_strategy = false, the strategy succeeds without redirecting" do
    user = enable_otp_and_sign_in
    Capybara.reset_sessions!

    Devise.otp_challenge_via_strategy = false

    visit posts_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: user.password
    page.has_content?("Log in") ? click_button("Log in") : click_button("Sign in")

    # Strategy did not redirect to otp_credential; the sign-in succeeded as if no OTP
    # were required. Controllers are then responsible for driving the OTP challenge.
    assert_equal posts_path, current_path
  end
end
