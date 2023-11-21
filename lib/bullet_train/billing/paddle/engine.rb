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

        initializer "bullet_train-billing-paddle.quantity" do
          ActiveSupport::Notifications.subscribe("memberships.provider-subscription-quantity-changed") do |name, start, finish, id, payload|
            # updating the included price quantity is handled in the subscription.update webhook
            ::Paddle::Subscription.update(
              id: payload[:provider_subscription].paddle_subscription_id,
              proration_billing_mode: :prorated_immediately,
              items: [{
                price_id: ::Billing::Paddle::PriceAdapter.new(payload[:included_price].price).paddle_price_id,
                quantity: payload[:quantity]
              }]
            )
          end
        end

        initializer "bullet_train-billing.integrate" do
          config.after_initialize do
            if defined?(BulletTrain::Billing.provider_subscription_attributes)
              BulletTrain::Billing.provider_subscription_attributes << :paddle_subscription_id
            end
          end
        end
      end
    end
  end
end
