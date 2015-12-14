Rails.application.routes.draw do

  devise_for :users

  #constraints subdomain: 'api' do
    namespace :api do
      namespace :v1 do
        resources :users, :items, :locations, :prices, :ratings, :reviews, :transactions, :sessions
      end
    end
  #end

  root 'home#landing'

  get 'search' => "search#search"

  get 'additem' => 'items#additem'
  get 'create' => 'registrations#create'

  concern :reviewable do
    resources :ratings, only: [:new, :create, :show, :edit, :update, :destroy]
    resources :reviews, only: [:show, :edit, :update, :create, :destroy]
  end

  resources :users

  resources :items,                                 :concerns => :reviewable
end
