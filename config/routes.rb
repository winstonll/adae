Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  root 'items#landing'

  get 'additem' => 'items#additem'
  get 'create' => 'registrations#create'

  concern :reviewable do
    resources :ratings, only: [:new, :create, :show, :edit, :update, :destroy]
    resources :reviews, only: [:show, :edit, :update, :create, :destroy]
  end

  resources :items,                                 :concerns => :reviewable
end
