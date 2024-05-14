require 'rails_helper'

RSpec.describe "Products API", type: :request do
  let(:buyer) {
      User.create!(
        email: "buyer@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :buyer
      )
  }
  let(:seller) {
      User.create!(
        email: "seller@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :seller
      )
  }

  let(:credential) {
    Credential.create_access(:buyer)
  }
  let(:signed_in) { api_sign_in(buyer, credential) }

  describe "GET /stores/:store_id/products" do
    it "returns a list of products empty" do
      store = Store.create!(name: "Test Store", user_id: seller.id)
      get(
        "/stores/#{store.id}/products",
        headers: {
          "Accept" => "application/json", 
          "X-API-KEY" => credential.key,
          "Authorization" => "Bearer #{signed_in["token"]}"
        }
      )

      expect(JSON.parse(response.body)).to eq( "products" => [] )
    end

    it "returns a list of products" do
      store = Store.create!(name: "Test Store", user_id: seller.id)
      product = Product.create!(title: "Bread", price: 1.50, store_id: store.id)
      get(
        "/stores/#{store.id}/products",
        headers: {
          "Accept" => "application/json", 
          "X-API-KEY" => credential.key,
          "Authorization" => "Bearer #{signed_in["token"]}"
        }
      )

      expect(JSON.parse(response.body)).to eq( {"products" => [{
        "id" => product.id,
        "store_id" => store.id,
        "title" => product.title,
        "price" => product.price.to_s
      }]} )
    end
  end


end