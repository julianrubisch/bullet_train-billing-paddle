module BulletTrain
  module Billing
    module Paddle
      class Engine < ::Rails::Engine
        initializer "bullet_train-billing-paddle.configure" do
          ::PaddlePay.configure do |config|
            config.environment = (Rails.env.development? || Rails.env.test?) ? :development : :production
            config.vendor_id = ENV["PADDLE_VENDOR_ID"]
            config.vendor_auth_code = ENV["PADDLE_VENDOR_AUTH_CODE"]
          end
        end
      end
    end
  end
end
