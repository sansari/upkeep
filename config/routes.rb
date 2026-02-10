Rails.application.routes.draw do
  root "dashboard#index"

  resources :areas, only: [ :index, :show ]
  resources :equipment, only: [ :show ]
  resources :maintenance_tasks, path: "tasks", only: [ :show ] do
    member do
      post :complete
    end
  end
  resources :supplies, only: [ :index ]

  get "up" => "rails/health#show", as: :rails_health_check
end
