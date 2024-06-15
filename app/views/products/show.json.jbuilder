json.extract! @product, :id, :title, :price, :store_id
json.image_url url_for(@product.image) if @product.image.attached?
