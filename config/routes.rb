Rails.application.routes.draw do
  root 'items#homepage'

  resources :items

  resources :users
  resources :sessions, only: [:new, :create, :destroy]

end