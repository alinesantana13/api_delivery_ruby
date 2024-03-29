require "rails_helper"
RSpec.describe "/stores", type: :request do
    describe "GET /show" do
        it "renders a successful response with stores data" do
            user = FactoryBot.create(:user)
            sign_in user
            store = Store.create!(name: "New Store", user: user)
            get "/stores/#{store.id}", headers: {"Accept" => "application/json"}
            json = JSON.parse(response.body)
            
            expect(json["name"]).to eq "New Store"
        end
    end
end