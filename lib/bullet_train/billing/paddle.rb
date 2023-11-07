require "bullet_train/billing/paddle/version"
require "bullet_train/billing/paddle/engine"
require "paddle"

module BulletTrain
  module Billing
    module Paddle
      # Your code goes here...
    end
  end
end

def paddle_billing_enabled?
  ENV["PADDLE_API_KEY"].present?
end
