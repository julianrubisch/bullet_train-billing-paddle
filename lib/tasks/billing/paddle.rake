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
        paddle_product_id = product[:paddle_id]

        unless product.prices.any?
          puts "Skipping `#{product[:id]}` because it has no prices associated with it.".yellow
          next
        end

        begin
          name = [I18n.t("application.name"), I18n.t("billing/products.#{product.id}.name")].join(" ")
          # first check whether the product already exists.
          paddle_product = Paddle::Product.retrieve(id: paddle_product_id)
          raise Paddle::Error if paddle_product.status == "archived"

          puts "Verified `#{paddle_product.id}` exists as a product on Paddle.".yellow

          paddle_product.name = name
          paddle_product.save

          puts "Updated name of `#{paddle_product.id}` to \"#{name}\".".green
        rescue Paddle::Error => _
          # if it doesn't already exist, create it.
          paddle_product = Paddle::Product.create(
            name: name,
            tax_category: "standard"
          )
          puts "Created `#{product.id}`.".green
          puts "Please add a `paddle_id` key to product '#{product.id}' with '#{paddle_product.id}' in your config/models/billing/products.yml".yellow
        end

        # e.g. [:month, :year].each do ...
        product.prices.each do |price|
          description = [I18n.t("application.name"), I18n.t("billing/products.#{product.id}.name"), "#{price.interval}ly"].join(" ")
          paddle_prices = Paddle::Price.list(product_id: paddle_product.id, status: "active").data

          price_adapter = Billing::Paddle::PriceAdapter.new(price)

          if (paddle_price = paddle_prices.detect { |paddle_price| price_adapter.matches_paddle_price?(paddle_price) })
            puts "Verified a price similar to the `#{price.id}` price exists for `#{paddle_product.id}`.".yellow
          else
            # if this product doesn't already haves a price at the appropriate interval, create it.
            arguments = {
              product_id: paddle_product.id,
              description: description,
              amount: price.amount.to_s,
              currency: price.currency,
              billing_cycle: {
                interval: price.interval,
                frequency: price.duration
              },
            }

            if !!price.trial_days
              arguments[:trial_period] = {
                interval: "day",
                frequency: price.trial_days
              }
            end

            paddle_price = Paddle::Price.create(**arguments)
            puts "Created `#{price.id}` as a `#{price.interval}` price for `#{paddle_product.id}`.".green
          end

          results[price_adapter.env_key] = paddle_price.id
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
