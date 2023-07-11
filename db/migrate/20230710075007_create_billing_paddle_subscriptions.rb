class CreateBillingPaddleSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :billing_paddle_subscriptions do |t|
      t.references :team, null: false, foreign_key: true
      t.string :paddle_subscription_id

      t.timestamps
    end
  end
end
