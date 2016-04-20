json.message @messages do |message|
  json.merge! message.attributes
end
