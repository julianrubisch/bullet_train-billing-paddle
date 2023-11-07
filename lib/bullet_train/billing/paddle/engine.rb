module BulletTrain
  module Billing
    module Paddle
      class Engine < ::Rails::Engine
        initializer "bullet_train-billing-paddle.configure" do
          ::Paddle.configure do |config|
            config.environment = (Rails.env.development? || Rails.env.test?) ? :development : :production
            config.api_key = ENV["PADDLE_API_KEY"]
          end
        end
      end
    end
  end
end
