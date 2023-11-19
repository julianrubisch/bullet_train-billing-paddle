class Billing::Paddle::Subscription < ApplicationRecord
  belongs_to :team
  has_one :generic_subscription, class_name: "Billing::Subscription", as: :provider_subscription

  def paddle_items
    generic_subscription.included_prices.map do |included_price|
      {
        price_id: Billing::Paddle::PriceAdapter.new(included_price.price).paddle_price_id,
        quantity: included_price.quantity
      }
    end
  end

  def paddle_update_url
    Paddle::Subscription.retrieve(id: paddle_subscription_id).management_urls.update_payment_method
  end

  def paddle_cancel_url
    Paddle::Subscription.retrieve(id: paddle_subscription_id).management_urls.cancel
  end

  def update_included_prices(subscription_items)
    remaining_included_prices = []

    subscription_items.each do |subscription_item|
      paddle_price_id = subscription_item.dig("price", "id")

      # See if we're already including a matching price locally.
      price = Billing::Paddle::PriceAdapter.find_by_paddle_price_id(paddle_price_id)
      included_price = generic_subscription.included_prices.find_or_initialize_by(price_id: price.id)
      included_price.quantity = subscription_item.dig("quantity")
      included_price.save

      remaining_included_prices << included_price
    end

    # Clean up any old prices that were on file but are no longer on the Paddle subscription.
    generic_subscription.included_prices.where.not(id: remaining_included_prices.pluck(:id)).destroy_all
  end
end
