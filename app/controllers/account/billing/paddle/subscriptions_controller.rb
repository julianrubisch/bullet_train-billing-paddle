class Account::Billing::Paddle::SubscriptionsController < Account::ApplicationController
  account_load_and_authorize_resource :subscription, through: :team, through_association: :billing_paddle_subscriptions, member_actions: [:checkout, :refresh, :portal]

  layout "pricing"

  # GET/POST /account/billing/paddle/subscriptions/:id/checkout
  # GET/POST /account/billing/paddle/subscriptions/:id/checkout.json
  def checkout
  end

  def refresh
    # could be done akin to Stripe with https://developer.paddle.com/api-reference/89c1805d821c2-list-transactions, but we have no access to the checkout_id here
    # so we're just redirecting with a notice
    redirect_to [:account, @subscription.generic_subscription.team], notice: t("billing/paddle/subscriptions.notifications.refreshed")
  end
end
