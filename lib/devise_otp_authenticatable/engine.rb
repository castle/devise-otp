module DeviseOtpAuthenticatable
  class Engine < ::Rails::Engine
    initializer "devise-otp", group: :all do |app|
      ActiveSupport.on_load(:devise_controller) do
        include DeviseOtpAuthenticatable::Controllers::UrlHelpers
        include DeviseOtpAuthenticatable::Controllers::Helpers
        include DeviseOtpAuthenticatable::Controllers::PublicHelpers
      end

      ActiveSupport.on_load(:action_view) do
        include DeviseOtpAuthenticatable::Controllers::UrlHelpers
        include DeviseOtpAuthenticatable::Controllers::Helpers
        include DeviseOtpAuthenticatable::Controllers::PublicHelpers
      end
    end
  end
end
