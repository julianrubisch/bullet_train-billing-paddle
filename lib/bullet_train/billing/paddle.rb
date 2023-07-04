require "bullet_train/billing/paddle/version"
require "bullet_train/billing/paddle/engine"
require "paddle_pay"

module BulletTrain
  module Billing
    module Paddle
      # Your code goes here...
    end
  end
end

def paddle_billing_enabled?
  ENV["PADDLE_VENDOR_ID"].present? && ENV["PADDLE_VENDOR_AUTH_CODE"].present?
end
