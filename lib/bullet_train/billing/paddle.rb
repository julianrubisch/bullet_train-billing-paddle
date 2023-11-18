require "bullet_train/billing/paddle/version"
require "bullet_train/billing/paddle/engine"
require "paddle"

module BulletTrain
  module Billing
    module Paddle
      module Teams
        module Base
          extend ActiveSupport::Concern

          included do
            has_many :billing_paddle_subscriptions, class_name: "Billing::Paddle::Subscription", dependent: :destroy, foreign_key: :team_id
          end
        end
      end

      module AbilitySupport
        def apply_billing_abilities(user)
          super
          can :read, ::Billing::Paddle::Subscription, team_id: user.team_ids
          can :manage, ::Billing::Paddle::Subscription, team_id: user.administrating_team_ids
          can [:update], ::Billing::Subscription, team_id: user.administrating_team_ids
        end
      end
    end
  end
end

def paddle_billing_enabled?
  ENV["PADDLE_API_KEY"].present?
end

ActiveSupport.on_load(:bullet_train_teams_base) { include BulletTrain::Billing::Paddle::Teams::Base }
ActiveSupport.on_load(:bullet_train_billing_ability_support) { prepend BulletTrain::Billing::Paddle::AbilitySupport }
