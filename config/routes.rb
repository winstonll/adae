Rails.application.routes.draw do
  devise_for :users
  root 'items#landing'

  get 'additem' => 'items#additem'

  concern :reviewable do
    resources :ratings, only: [:new, :create, :show, :edit, :update, :destroy]
    resources :reviews, only: [:show, :edit, :update, :create, :destroy]
  end

  resources :items,                                 :concerns => :reviewable

  resources :users
  resources :sessions, only: [:new, :create, :destroy]

end
