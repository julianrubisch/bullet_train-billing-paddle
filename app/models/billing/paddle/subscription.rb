class Billing::Paddle::Subscription < ApplicationRecord
  belongs_to :team
  has_one :generic_subscription, class_name: "Billing::Subscription", as: :provider_subscription

  def paddle_items
    generic_subscription.included_prices.map do |included_price|
      {
        plan: Billing::Paddle::PriceAdapter.new(included_price.price).paddle_subscription_plan_id,
        quantity: included_price.quantity
      }
    end
  end
end