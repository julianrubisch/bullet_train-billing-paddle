class Account::Billing::Paddle::SubscriptionsController < Account::ApplicationController
  account_load_and_authorize_resource :subscription, through: :team, through_association: :billing_paddle_subscriptions, member_actions: [:cancel, :checkout, :refresh, :portal]

  layout "pricing"

  # GET/POST /account/billing/paddle/subscriptions/:id/checkout
  # GET/POST /account/billing/paddle/subscriptions/:id/checkout.json
  def checkout
  end

  # DELETE /account/billing/paddle/subscriptions/:id/cancel
  # DELETE /account/billing/paddle/subscriptions/:id/cancel.json
  def cancel
    PaddlePay::Subscription::User.cancel(@subscription.paddle_subscription_id)
    redirect_to [:account, @subscription.generic_subscription.team], notice: t("billing/paddle/subscriptions.notifications.canceled")
  end

  # GET /account/billing/paddle/subscriptions/:id/portal
  # GET /account/billing/paddle/subscriptions/:id/portal.json
  def portal
    redirect_to @subscription.paddle_update_url, allow_other_host: true
  end

  # GET /account/billing/paddle/subscriptions/:id/refresh
  # GET /account/billing/paddle/subscriptions/:id/refresh.json
  def refresh
    # could be done akin to Stripe with https://developer.paddle.com/api-reference/89c1805d821c2-list-transactions, but we have no access to the checkout_id here
    # so we're just redirecting with a notice
    redirect_to [:account, @subscription.generic_subscription.team], notice: t("billing/paddle/subscriptions.notifications.refreshed")
  end
end
