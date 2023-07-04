namespace :billing do
  namespace :paddle do
    desc "Populate the Paddle account with the required products."
    task populate_products_in_paddle: :environment do
      unless paddle_billing_enabled?
        # TODO Improve this error message and point them to some "getting started" documentation.
        puts "Paddle isn't enabled.".red
        next
      end

      results = {}

      # for each product or service level ..
      # e.g. [:basic, :pro].each ...
      Billing::Product.all.each do |product|
        # ensure a paddle product with the appropriate key exists.
        paddle_product_id = "#{I18n.t("application.key")}_#{product.id}"

        unless product.prices.any?
          puts "Skipping `#{paddle_product_id}` because it has no prices associated with it.".yellow
          next
        end

        # e.g. [:month, :year].each do ...
        product.prices.each do |price|
          name = [I18n.t("application.name"), I18n.t("billing/products.#{product.id}.name"), "#{price.interval}ly"].join(" ")

          # first check whether the product already exists.
          paddle_subscription_plans = PaddlePay::Subscription::Plan.list

          if paddle_subscription_plans.find { _1[:name] == name }
            puts "Verified `#{name}` exists as a subscription plan on Paddle.".yellow
            next
          end

          response_create = PaddlePay::Subscription::Plan.create(
            plan_name: name,
            plan_trial_days: price.trial_days,
            plan_length: price.duration,
            plan_type: price.interval,
            main_currency_code: price.currency,
            recurring_price_usd: price.amount.to_f / 100
          )

          # if it doesn't already exist, create it.
          puts "Created subscription plan with ID `#{response_create[:product_id]}`.".green if response_create[:product_id].present?
        end
      end

      puts "\nOK, put the following in `config/application.yml` or wherever you configure your environment values:\n".green

      results.each do |key, value|
        puts "#{key}: #{value}".green
      end

      puts "\n"
      # puts "In addition to enabling local development, those `price_*` values also let Bullet Train's test suite know what plans are available on Paddle for testing it's subscription workflows.".green
      puts "\n"
    end
  end
end
