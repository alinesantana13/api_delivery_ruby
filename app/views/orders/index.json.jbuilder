json.array! @orders do |order|
  json.id order.id
  json.buyer_id order.buyer_id
  json.store_id order.store_id
  json.state order.state
  json.created_at order.created_at
  json.total_order_items number_to_currency(order.order_items.sum { |order_item| order_item.price })

  json.order_items order.order_items do |order_item|
    json.product_title order_item.product.title
    json.amount order_item.amount
    json.price order_item.price
  end
end
