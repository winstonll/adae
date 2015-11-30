Rails.application.routes.draw do
  #mount_devise_token_auth_for 'User', at: 'auth'

  devise_for :users, controllers: { sessions: "users/sessions" }

  #namespace :api do
  #  resources :items, :users
  #end

  namespace :api do
    resources :users
  end

  root 'items#landing'

  get 'additem' => 'items#additem'
  get 'create' => 'registrations#create'

  concern :reviewable do
    resources :ratings, only: [:new, :create, :show, :edit, :update, :destroy]
    resources :reviews, only: [:show, :edit, :update, :create, :destroy]
  end

  resources :items,                                 :concerns => :reviewable
end
