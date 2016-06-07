Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'signup',  to: 'users/registrations#new'
    get 'signin',  to: 'users/sessions#new'
    delete 'signout', to: 'users/sessions#destroy'
  end

  get 'signup_modal' => 'home#signup_modal'
  get 'signup_modal' => 'users/home#signup_modal'
  get 'signin_modal' => 'home#signin_modal'
  get 'signin_modal' => 'users/home#signin_modal'
  get 'companion_modal' => 'home#companion_modal'
  post 'discount' => 'items#discount'

  #constraints subdomain: 'api' do
    namespace :api do
      namespace :v1 do
        resources :users, :items, :locations, :prices, :ratings, :reviews, :transactions, :sessions, :conversations, :messages
      end
      
      namespace :v2 do
        resources :users, :items, :locations, :prices, :ratings, :reviews, :transactions, :sessions, :conversations, :messages
      end
    end
  #end

  resources :conversations do
    resources :messages
  end

  root 'home#landing'

  get 'search' => "search#search"
  get 'cancel' => 'transactions#cancel'
  get 'accept' => 'transactions#accept'

  get '/api/v1/verify_scan/' => 'api/v1/transactions#verify_scan'
  get '/api/v1/transaction_detail/:id' => 'api/v1/transactions#transaction_detail'

  # simple/static pages
    get 'terms'   => "home#terms",   as: :terms
    get 'about'   => "home#about",   as: :about
    get 'faq'     => "home#faq",     as: :faq
    get 'careers' => "home#careers", as: :careers
    get 'privacy' => "home#privacy", as: :privacy
    match '/contact' => 'contacts#new', :via => :get
    match '/contact' => 'contacts#create', :via => :post
    post :system_message, to: 'requests#system_message', as: :system_message


  concern :reviewable do
    resources :ratings, only: [:new, :create, :show, :edit, :update, :destroy]
    resources :reviews, only: [:show, :edit, :update, :create, :destroy]
  end

  get 'users/stripe_settings/' => 'users#stripe_settings', :to => "users_stripe_settings"
  post 'users/stripe_update_settings/' => 'users#stripe_update_settings', :to => "users_stripe_update_settings"

  post 'transactions/stripe/' => 'transactions#stripe', :to =>"transactions_stripe"
  get 'transactions/stripe_success/:id' => 'transactions#stripe_success', :to => "transactions_stripe_success"

  # - Stripe routes
  # - Create accounts
  post '/connect/managed' => 'stripe#managed', as: 'stripe_managed'
    # Stripe webhooks
  post '/hooks/stripe' => 'hooks#stripe'
  post 'transactions/hook' => 'transactions#hook', :to => "transactions_hook"

  resources :items,  :concerns => :reviewable, :path => "listings"
  resources :requests, :path => "shoutouts"
  resources :users
  resources :locations
  resources :transactions

  get 'sell'   => "items#sell",   as: :sell
  get 'rent'   => "items#rent",   as: :rent
  get 'lease'   => "items#lease",   as: :lease
  get 'timeoffer'   => "items#timeoffer",   as: :timeoffer

end
