json.array! @stores do |store|
  json.id store.id
  json.name store.name
  json.user_id store.user_id
end
