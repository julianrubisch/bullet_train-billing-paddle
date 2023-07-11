class Account::Billing::Paddle::SubscriptionsController < Account::ApplicationController
  account_load_and_authorize_resource :subscription, through: :team, through_association: :billing_paddle_subscriptions, member_actions: [:checkout, :refresh, :portal]

  # GET/POST /account/billing/paddle/subscriptions/:id/checkout
  # GET/POST /account/billing/paddle/subscriptions/:id/checkout.json
  def checkout
    binding.irb
    # trial_days = @subscription.generic_subscription.included_prices.map { |ip| ip.price.trial_days }.compact.max

    # session_attributes = {
    #   payment_method_types: ["card"],
    #   subscription_data: {items: @subscription.paddle_items}.merge(trial_days ? {trial_period_days: trial_days} : {}),
    #   customer: @team.paddle_customer_id,
    #   client_reference_id: @subscription.id,
    #   success_url: CGI.unescape(url_for([:refresh, :account, @subscription, session_id: "{CHECKOUT_SESSION_ID}"])),
    #   cancel_url: url_for([:account, @subscription.generic_subscription])
    # }

    # unless @team.paddle_customer_id
    #   session_attributes[:customer_email] = current_membership.email
    # end
    
    # Paddle requires that Checkout Sessions having different attributes must
    # have different idempotency keys, so include the updated_at in the key.
    # idempotency_key = "#{t('application.name')}:subscription:#{@subscription.id}:#{@subscription.updated_at.to_i}"

    # session = Paddle::Checkout::Session.create(session_attributes, idempotency_key: idempotency_key)

    # redirect_to session.url, allow_other_host: true
  end
end
