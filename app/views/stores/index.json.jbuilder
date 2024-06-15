json.result do
  if params[:page].present?
    json.pagination do
      current = @stores.current_page
      total = @stores.total_pages
      per_page = @stores.limit_value

      json.current current
      json.per_page per_page
      json.pages total
      json.count @stores.total_count
      json.previous (current > 1 ? (current - 1) : nil)
      json.next (current == total ? nil : (current + 1))
    end
  end

  json.stores do
    json.array! @stores do |store|
      json.id store.id
      json.name store.name
      json.user_id store.user_id
      json.image_url url_for(store.image) if store.image.attached?
    end
  end
end
