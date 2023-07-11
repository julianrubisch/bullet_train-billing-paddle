class Account::Billing::Paddle::SubscriptionsController < Account::ApplicationController
  account_load_and_authorize_resource :subscription, through: :team, through_association: :billing_paddle_subscriptions, member_actions: [:checkout, :refresh, :portal]

  layout "pricing"

  # GET/POST /account/billing/paddle/subscriptions/:id/checkout
  # GET/POST /account/billing/paddle/subscriptions/:id/checkout.json
  def checkout
  end
end
