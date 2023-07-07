Rails.application.routes.draw do
  namespace :webhooks do
    namespace :incoming do
      resources :paddle_webhooks
    end
  end
end
