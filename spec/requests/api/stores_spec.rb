require "rails_helper"

RSpec.describe "/stores", type: :request do
    let(:admin) { FactoryBot.create(:user, :admin) }
    let(:seller) { FactoryBot.create(:user, :seller) }
    let(:seller_verify) { FactoryBot.create(:user, :seller) }
    let(:buyer) { FactoryBot.create(:user, :buyer) }

    let(:credential_seller) { Credential.create_access(:seller )}
    let(:credential_buyer) { Credential.create_access(:buyer)}

    let(:signed_in_seller) { api_sign_in(seller, credential_seller) }
    let(:signed_in_buyer) { api_sign_in(buyer, credential_buyer) }
    let(:signed_in_seller_verify) { api_sign_in(seller_verify, credential_seller) }

    let(:store) { FactoryBot.create(:store, user: seller) }

    describe "GET /show" do
        it "renders a successful response with stores data" do
            store = Store.create!(name: "New Store", user: seller)
            get(
                "/stores/#{store.id}", 
                headers: {
                    "Accept" => "application/json",
                    "Authorization" => "Bearer #{signed_in_seller["token"]}"
                }
            )
            json = JSON.parse(response.body)
            
            expect(json["name"]).to eq "New Store"
        end
    end

    describe "DELETE /destroy" do
        context "as a buyer" do
            it "buyer not authorized to delete store" do
                # store = Store.create!(name: "New Store", user: seller)
                delete(
                    "/stores/#{store.id}", 
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                    }
                )
                expect(response).to have_http_status(:unauthorized)
                expect(JSON.parse(response.body)['message']).to eq('Not authorized')
            end
        end

        context "as a seller" do
            it "seller makes logical deletion of existing store and its" do
                timestamp_before = Time.current.to_i
                delete(
                    "/stores/#{store.id}", 
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                expect(response).to have_http_status(:no_content)
                store.reload
                expect(store.deleted_at_timestamp).not_to be_nil
                expect(store.deleted_at_timestamp).to be >= timestamp_before
                expect(store.deleted_at_timestamp).to be <= Time.current.to_i

                delete(
                    "/stores/#{store.id}", 
                    headers: {
                    "Accept" => "application/json",
                    "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                
                expect(response).to have_http_status(:not_found)
            end

            it "seller tries to delete a store that is not his" do
                store_verify = Store.create!(name: "New Store Test", user: seller_verify)
                delete(
                    "/stores/#{store_verify.id}", 
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    },
                )
                expect(JSON.parse(response.body)['message']).to eq('Store not found!')
            end

            it "seller tries to delete a store that doesn't exist" do
                delete(
                    "/stores/99999", 
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    },
                )
                expect(JSON.parse(response.body)['message']).to eq('Store not found!')
            end
            
        end

        context "as a admin" do
            it "redirects to stores_url with notice when trying to delete a non-existent store" do
                sign_in admin

                delete store_url(9999) 
                expect(response).to redirect_to(stores_url)
                expect(flash[:notice]).to eq("Store not found!")
            end

            it "admin deletes existing store" do
                sign_in admin

                delete store_url(store) 
                expect(response).to redirect_to(stores_url)
                expect(flash[:notice]).to eq("Store was successfully destroyed.")
            end
        end

    end
end