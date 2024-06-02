require "rails_helper"

RSpec.describe "/stores", type: :request do
  let(:seller) { FactoryBot.create(:user, :seller) }
  let(:seller_verify) { FactoryBot.create(:user, :seller) }
  let(:buyer) { FactoryBot.create(:user, :buyer) }

  let(:credential_seller) { Credential.create_access(:seller )}
  let(:credential_buyer) { Credential.create_access(:buyer)}

  let(:signed_in_seller) { api_sign_in(seller, credential_seller) }
  let(:signed_in_buyer) { api_sign_in(buyer, credential_buyer) }
  let(:signed_in_seller_verify) { api_sign_in(seller_verify, credential_seller) }

  let(:store) { FactoryBot.create(:store, user: seller) }

    describe "GET /index" do
        context "as a seller" do
            it "list all stores of the current seller" do
                Store.create!(name: "New Store 1", user: seller)
                Store.create!(name: "New Store 2", user: seller)
                Store.create!(name: "New Store 3", user: seller)
                Store.create!(name: "New Store 4", user: seller_verify)

                get(
                    "/stores",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )

                json = JSON.parse(response.body)
                expect(json.length).to eq(3)

                store_names = json.map { |store| store["name"] }
                expect(store_names).to include("New Store 1", "New Store 2", "New Store 3")
            end

            it "seller without registered store" do
                get(
                    "/stores",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                expect(JSON.parse(response.body).length).to eq(0)
            end
        end

        context "as a buyer" do
            it "buyer can see all stores" do
                Store.create!(name: "New Store 1", user: seller)
                Store.create!(name: "New Store 2", user: seller)
                Store.create!(name: "New Store 3", user: seller)
                Store.create!(name: "New Store 4", user: seller_verify)
                get(
                    "/stores",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                    }
                )

                expect(JSON.parse(response.body).length).to eq(4)
            end
        end
    end

    describe "GET /show" do
        context "as a seller" do
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

            it "seller cannot access another user's store" do
                store_verify = Store.create!(name: "Pastry shop", user: seller_verify)
                get(
                    "/stores/#{store_verify.id}",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )

                expect(JSON.parse(response.body)['message']).to eq('Store not found')
            end

            it "seller tries to access store that has been deleted" do
                store = Store.create!(name: "Pastry shop", user: seller)
                delete(
                    "/stores/#{store.id}",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                expect(response).to have_http_status(:no_content)

                get(
                    "/stores/#{store.id}",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )

                expect(JSON.parse(response.body)['message']).to eq('Store not found!')
            end
        end

        context "as a buyer" do
            it "buyer can access any store that is not excluded" do
                get(
                    "/stores/#{store.id}",
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                    }
                )

                expect(JSON.parse(response.body)).to eq( {
                    "id" => store.id,
                    "name" => store.name,
                    "user_id" => store.user_id,
                } )
            end
        end
    end

    describe "POST /create" do
      context "as a seller" do
          it "seller create store" do
              post(
                  "/stores",
                  headers: {
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{signed_in_seller["token"]}"
                  },
                  params: {
                    store: {
                      name: "Test create"
                    }
                  }
              )

              json = JSON.parse(response.body)
              expect(json['name']).to eq("Test create")
          end
      end

      context "as a buyer" do
          it "
          buyer trying to create store" do
              post(
                  "/stores",
                  headers: {
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                  },
                  params: {
                    store: {
                      name: "Test create"
                    }
                  }
              )

              expect(response).to have_http_status(:unauthorized)
              expect(JSON.parse(response.body)['message']).to eq('Not authorized')
          end
      end
    end

    describe "PUT /update" do
      context "as a seller" do
          it "seller update store" do
            store = Store.create!(name: "New Store", user: seller)
            store_name = store.name
              put(
                  "/stores/#{store.id}",
                  headers: {
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{signed_in_seller["token"]}"
                  },
                  params: {
                    store: {
                      name: "Test create"
                    }
                  }
              )

              json = JSON.parse(response.body)
              expect(json['name']).to eq("Test create")
              store.reload
              expect(store.name).not_to eq(store_name)
              expect(store.name).to eq("Test create")
          end
      end

      context "as a buyer" do
          it "
          buyer trying to update store" do
            store = Store.create!(name: "New Store", user: seller)
              put(
                  "/stores/#{store.id}",
                  headers: {
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                  },
                  params: {
                    store: {
                      name: "Test create"
                    }
                  }
              )
              expect(response).to have_http_status(:unauthorized)
              expect(JSON.parse(response.body)['message']).to eq('Not authorized')
          end
      end
    end

    describe "DELETE /destroy" do
        context "as a buyer" do
            it "buyer not authorized to delete store" do
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
    end
end
