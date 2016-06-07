json.ongoing @ongoing do |t_o|
  json.merge! t_o.attributes
end

json.item_og @item_og do |i_og|
  json.merge! i_og.attributes
end

json.user_og @user_og do |u_og|
  json.id u_og.id
  json.phone_number u_og.phone_number
  json.phone_verified u_og.phone_verified
  json.surname  u_og.surname
  json.stripe_currency u_og.stripe_currency
  json.balance u_og.balance
  json.stripe_user_id u_og.stripe_user_id
  json.stripe_account_status u_og.stripe_account_status
  json.email u_og.email
  json.name u_og.name
  json.stripe_account_type u_og.stripe_account_type
end

json.completed @completed do |t_c|
  json.merge! t_c.attributes
end

json.item_co @item_co do |i_co|
  json.merge! i_co.attributes
end

json.user_co @user_co do |u_co|
  json.id u_co.id
  json.phone_number u_co.phone_number
  json.phone_verified u_co.phone_verified
  json.surname  u_co.surname
  json.stripe_currency u_co.stripe_currency
  json.balance u_co.balance
  json.stripe_user_id u_co.stripe_user_id
  json.stripe_account_status u_co.stripe_account_status
  json.email u_co.email
  json.name u_co.name
  json.stripe_account_type u_co.stripe_account_type
end
