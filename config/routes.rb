Rails.application.routes.draw do
  namespace :webhooks do
    namespace :incoming do
      resources :paddle_webhooks
    end
  end

  namespace :paddle do
    get "payment"
  end

  namespace :account do
    shallow do
      resources :teams, only: [] do
        namespace :billing do
          resources :subscriptions, only: [] do
            namespace :paddle do
              resources :subscriptions do
                member do
                  get :cancel
                  post :checkout
                  get :checkout
                  get :history
                  get :portal
                  get :refresh
                end
              end
            end
          end
        end
      end
    end
  end
end
