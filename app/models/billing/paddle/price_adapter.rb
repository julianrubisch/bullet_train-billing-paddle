class Billing::Paddle::PriceAdapter
  def initialize(price)
    @price = price
  end

  def env_key
    "PADDLE_PRODUCT_#{@price.id}_PRICE_ID".upcase
  end

  def paddle_subscription_plan_id
    ENV[env_key]
  end

  def matches_paddle_price?(paddle_price)
    @price.amount.to_s == paddle_price.unit_price.amount &&
      @price.interval == paddle_price.billing_cycle.interval &&
      @price.duration == paddle_price.billing_cycle.frequency
  end

  def self.find_by_paddle_price_id(price_id)
    Billing::Price.all.detect { |price| new(price).paddle_price_id == price_id }
  end
end
