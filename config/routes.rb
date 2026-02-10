Rails.application.routes.draw do
  root "dashboard#index"

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :areas, only: [ :index, :show ]
  resources :equipment, only: [ :show ]
  resources :maintenance_tasks, path: "tasks", only: [ :show ] do
    member do
      post :complete
    end
  end
  resources :supplies, only: [ :index ]
  get "log" => "maintenance_logs#index", as: :log

  get "up" => "rails/health#show", as: :rails_health_check
end
