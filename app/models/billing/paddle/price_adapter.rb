class Billing::Paddle::PriceAdapter
  def initialize(price)
    @price = price
  end

  def env_key
    "PADDLE_SUBSCRIPTION_PLAN_#{@price.id}".upcase
  end

  def paddle_subscription_plan_id
    ENV[env_key]
  end

  def self.find_by_paddle_subscription_plan_id(subscription_plan_id)
    Billing::Price.all.detect { |price| new(price).paddle_subscription_plan_id == subscription_plan_id }
  end
end
