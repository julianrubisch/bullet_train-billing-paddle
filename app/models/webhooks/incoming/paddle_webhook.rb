class Webhooks::Incoming::PaddleWebhook < ApplicationRecord
  include Webhooks::Incoming::Webhook

  def process
    case data.with_indifferent_access
    in alert_name: "subscription_created"
      status = case subscription_status
      when "paused"
        "pending"
      when "trialing"
        "trialing"
      when "active"
        "active"
      when "past_due"
        "overdue"
      when "unpaid"
        "overdue"
      when "canceled"
        "canceled"
      end

      Billing::Paddle::Subscription.transaction do
        subscription.generic_subscription.update(status: status)
        subscription.update(paddle_subscription_id: paddle_subscription_id)
      end
    in alert_name: "subscription_updated"
    in alert_name: "subscription_cancelled"
      subscription.generic_subscription.update(status: "canceled")
    in alert_name: "subscription_payment_succeeded"
      # linking the team to a paddle user ID happens here, as opposed to Stripe, where it happens when the checkout refreshes
      # TODO a checkout_id is present in the payload, so we could use https://developer.paddle.com/api-reference/89c1805d821c2-list-transactions to refresh, but e.g. next_bill_date is missing?
      # but in https://developer.paddle.com/api-reference/e33e0a714a05d-list-users it's called next_payment.date
      Billing::Paddle::Subscription.transaction do
        subscription.update(paddle_subscription_id: paddle_subscription_id)
        subscription.team.update(paddle_customer_id: paddle_customer_id)
        subscription.generic_subscription.update(cycle_ends_at: Time.zone.parse(next_bill_date))
      end
    in alert_name: "subscription_payment_failed"
    in alert_name: "subscription_payment_refunded"
    end
  end

  def subscription_status
    data["status"]
  end

  def subscription
    Billing::Paddle::Subscription.find(passthrough["subscription_id"])
  end

  def paddle_subscription_id
    data["subscription_id"]
  end

  def paddle_customer_id
    data["user_id"]
  end

  def quantity
    data["quantity"]
  end

  def passthrough
    JSON.parse(data["passthrough"])
  end

  def custom_data
    data["custom_data"]
  end

  def next_bill_date
    data["next_bill_date"]
  end
end
