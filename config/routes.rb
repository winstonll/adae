Rails.application.routes.draw do

  devise_for :users#, controllers: { sessions: 'sessions' }

  #constraints subdomain: 'api' do
    namespace :api do
      namespace :v1 do
        resources :users, :items, :locations, :prices, :ratings, :reviews, :transactions, :sessions
      end
    end
  #end

  resources :conversations do
    resources :messages
  end

  root 'home#landing'

  get 'search' => "search#search"

  get 'create' => 'registrations#create'

  # simple/static pages
    get 'terms'   => "home#terms",   as: :terms
    get 'about'   => "home#about",   as: :about
    get 'faq'     => "home#faq",     as: :faq
    get 'careers' => "home#careers", as: :careers
    get 'privacy' => "home#privacy", as: :privacy


  concern :reviewable do
    resources :ratings, only: [:new, :create, :show, :edit, :update, :destroy]
    resources :reviews, only: [:show, :edit, :update, :create, :destroy]
  end

  resources :users
  resources :carts

  post 'carts/add/' => 'carts#add', :to => 'carts_add'


  resources :requests, :path => "shoutout"

  resources :items,  :concerns => :reviewable
  get 'sell'   => "items#sell",   as: :sell
  get 'rent'   => "items#rent",   as: :rent
  get 'lease'   => "items#lease",   as: :lease
  get 'timeoffer'   => "items#timeoffer",   as: :timeoffer

end
