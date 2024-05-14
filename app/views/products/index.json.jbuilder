json.products @products do |product|
  json.id product.id
  json.store_id product.store_id
  json.title product.title
  json.price product.price
end