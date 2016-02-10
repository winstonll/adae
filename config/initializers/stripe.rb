Rails.configuration.stripe = {
  :publishable_key => Rails.application.secrets.publishable_key,
  :secret_key      => Rails.application.secrets.secret_key
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]