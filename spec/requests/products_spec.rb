require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:seller) { FactoryBot.create(:user, :seller) }
  let(:buyer) { FactoryBot.create(:user, :buyer) }

  let(:store) { FactoryBot.create(:store, user: seller) }
  let(:product) {FactoryBot.create(:product, store: store)}
  describe "GET /index" do
    it "admin views all products" do
      sign_in(admin)
      get listing_url
      expect(response).to be_successful
      expect(Product.find_by(title: product.title).store).to eq store
    end
  end
end
