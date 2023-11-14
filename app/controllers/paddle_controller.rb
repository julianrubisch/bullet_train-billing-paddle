# frozen_string_literal: true

# this class implements the default payment link required by paddle billing, and should be linked to in your checkout settings on Paddle

class PaddleController < ApplicationController
  layout "pricing"

  def payment
  end
end
