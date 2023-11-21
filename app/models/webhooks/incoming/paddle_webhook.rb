class Webhooks::Incoming::PaddleWebhook < ApplicationRecord
  include Webhooks::Incoming::Webhook

  def process
    Rails.logger.debug(data.inspect)
    case data.with_indifferent_access
    in {event_type: "subscription.created"} | {event_type: "subscription.trialing"}
      # linking the team to a paddle user ID happens here, as opposed to Stripe, where it happens when the checkout refreshes
      Billing::Paddle::Subscription.transaction do
        subscription.generic_subscription.update(
          status: subscription_status,
          cycle_ends_at: Time.zone.parse(next_billed_at)
        )
        subscription.team.update(paddle_customer_id: paddle_customer_id)
        subscription.update(paddle_subscription_id: paddle_subscription_id)
        subscription.update_included_prices(data["data"]["items"])
      end
    in {event_type: "subscription.activated"} | {event_type: "subscription.updated"}
      Billing::Paddle::Subscription.transaction do
        subscription.generic_subscription.update(status: subscription_status)
        subscription.generic_subscription.update(cycle_ends_at: Time.zone.parse(next_billed_at)) if !!next_billed_at
        subscription.update_included_prices(data["data"]["items"])
      end
    in event_type: "subscription.canceled"
      subscription.generic_subscription.update(status: "canceled")
    in event_type: "subscription.paused"
      subscription.generic_subscription.update(status: "pending")
    in event_type: "subscription.resumed"
      subscription.generic_subscription.update(status: "active")
    in event_type: "transaction.completed"
    in event_type: "transaction.paid"
    in event_type: "transaction.payment_failed"
    # is there anything to do here? failed payments will be processed according to Payment Recovery, e.g. paused, which should be handled by the webhook
    # in Paddle Billing, that's handled by Retain https://developer.paddle.com/build/retain/configure-payment-recovery-dunning#subscription-status
    end
  end

  def subscription_status
    case data["data"]["status"]
    when "paused"
      "pending"
    when "trialing"
      "trialing"
    when "active"
      "active"
    when "past_due"
      "overdue"
    when "canceled"
      "canceled"
    end
  end

  def subscription
    Billing::Paddle::Subscription.find(custom_data["subscription_id"])
  end

  def paddle_subscription_id
    data["data"]["id"]
  end

  def paddle_customer_id
    data["data"]["customer_id"]
  end

  def custom_data
    data["data"]["custom_data"]
  end

  def next_billed_at
    data["data"]["next_billed_at"]
  end
end
