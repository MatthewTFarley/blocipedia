Rails.application.routes.draw do
  delete 'collaborations/destroy'

  get 'charges/create'

  get 'about' => 'welcome#about'
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  delete 'logout', to: 'sessions#destroy', as: 'logout'
  get '/users/:id/confirm', to: "users#confirm", as: 'confirm'
  get 'upgrade', to: "charges#new"
  get '/downgrade', to: "users#downgrade", as: 'downgrade'
  root to: 'welcome#index'
  
  resources :users, :wikis, :sessions
  resources :charges, only: [:new, :create]
end
