json.extract! @store, :id, :name, :user_id
json.image_url url_for(@store.image) if @store.image.attached?
