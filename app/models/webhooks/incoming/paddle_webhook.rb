class Webhooks::Incoming::PaddleWebhook < ApplicationRecord
  include Webhooks::Incoming::Webhook

  def process
    case data.with_indifferent_access
    in alert_name: "subscription_created"
      Billing::Paddle::Subscription.transaction do
        subscription.generic_subscription.update(status: subscription_status)
        subscription.update(paddle_subscription_id: paddle_subscription_id)
      end
    in alert_name: "subscription_updated"
      subscription.generic_subscription.update(status: subscription_status)
    in alert_name: "subscription_cancelled"
      subscription.generic_subscription.update(status: "canceled")
    in alert_name: "subscription_payment_succeeded"
      # linking the team to a paddle user ID happens here, as opposed to Stripe, where it happens when the checkout refreshes
      Billing::Paddle::Subscription.transaction do
        subscription.update(paddle_subscription_id: paddle_subscription_id)
        subscription.team.update(paddle_customer_id: paddle_customer_id)
        subscription.generic_subscription.update(cycle_ends_at: Time.zone.parse(next_bill_date))
      end
    in alert_name: "subscription_payment_failed"
    # is there anything to do here? failed payments will be processed according to "Recover Settings", e.g. paused, which should be handled by the webhook
    in alert_name: "subscription_payment_refunded"
    end
  end

  def subscription_status
    case data["status"]
    when "paused"
      "pending"
    when "trialing"
      "trialing"
    when "active"
      "active"
    when "past_due"
      "overdue"
    when "deleted"
      "canceled"
    end
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
