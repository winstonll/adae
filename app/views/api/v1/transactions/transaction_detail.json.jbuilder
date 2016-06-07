json.transaction @transaction do |transaction|
  json.merge! transaction.attributes
end

json.item @item do |item|
  json.merge! item.attributes
end

json.blah @user do |user|
  json.id user.id
  json.phone_number user.phone_number
  json.phone_verified user.phone_verified
  json.surname  user.surname
  json.stripe_currency user.stripe_currency
  json.balance user.balance
  json.stripe_user_id user.stripe_user_id
  json.stripe_account_status user.stripe_account_status
  json.email user.email
  json.name user.name
  json.stripe_account_type user.stripe_account_type
end
