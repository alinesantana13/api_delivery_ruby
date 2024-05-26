require 'rails_helper'

RSpec.describe "orders", type: :request do
  let(:seller) { FactoryBot.create(:user, :seller) }
  let(:buyer) { FactoryBot.create(:user, :buyer) }

  let(:credential) { Credential.create_access(:buyer)}
  let(:signed_in) { api_sign_in(buyer, credential) }

  let(:store) { FactoryBot.create(:store, user: seller) }

  describe "POST /buyers/orders" do
    it "create a order" do
      expect {
      post(
        "/buyers/orders",
        headers: {
        "Accept" => "application/json",
        "X-API-KEY" => credential.key,
        "Authorization" => "Bearer #{signed_in["token"]}"
        },
        params: {order: {store_id: store.id}}
      )}.to change(Order, :count).by(1)

      expect(response).to be_successful
    end
  end
end
