FactoryBot.define do
  factory :billing_paddle_subscription, class: "Billing::Paddle::Subscription" do
    team { nil }
    paddle_subscription_id { "sub_yyz" }
  end
end
