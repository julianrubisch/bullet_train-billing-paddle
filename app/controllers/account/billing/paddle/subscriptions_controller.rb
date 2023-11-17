class Account::Billing::Paddle::SubscriptionsController < Account::ApplicationController
  account_load_and_authorize_resource :subscription, through: :team, through_association: :billing_paddle_subscriptions, member_actions: [:cancel, :checkout, :history, :refresh, :portal]

  layout "pricing"

  # GET/POST /account/billing/paddle/subscriptions/:id/checkout
  # GET/POST /account/billing/paddle/subscriptions/:id/checkout.json
  def checkout
  end

  # GET /account/billing/paddle/subscriptions/:id/cancel
  # GET /account/billing/paddle/subscriptions/:id/cancel.json
  def cancel
    redirect_to @subscription.paddle_cancel_url, allow_other_host: true
  end

  # GET /account/billing/paddle/subscriptions/:id/history
  # GET /account/billing/paddle/subscriptions/:id/history.json
  def history
    @transactions = Paddle::Transaction.list(subscription_id: @subscription.paddle_subscription_id, status: "completed,canceled,past_due").data.select do
      next if _1.payments.empty?

      _1.payments.last.amount.to_f > 0
    end

    render :history, layout: "account"
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
