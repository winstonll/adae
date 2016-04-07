json.conversation @conversations do |conversation|
  json.merge! conversation.attributes
end

json.user @users do |user|
  json.id user.id
  json.surname  user.surname
  json.balance user.balance
  json.email user.email
  json.name user.name
end
