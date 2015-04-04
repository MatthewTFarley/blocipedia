Rails.application.routes.draw do
  get 'welcome/index'
  get 'welcome/about'
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  delete 'logout', to: 'sessions#destroy', as: 'logout'
  get '/users/:id/confirm', to: "users#confirm", as: 'confirm'
  root to: 'welcome#index'
  
  resources :users
  resources :sessions
end
