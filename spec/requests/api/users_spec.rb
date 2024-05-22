require "rails_helper"

RSpec.describe "/users", type: :request do
    let(:seller) { FactoryBot.create(:user, :seller) }
    let(:seller_verify) { FactoryBot.create(:user, :seller) }
    let(:buyer) { FactoryBot.create(:user, :buyer) }

    let(:credential_seller) { Credential.create_access(:seller )}
    let(:credential_buyer) { Credential.create_access(:buyer)}

    let(:signed_in_seller) { api_sign_in(seller, credential_seller) }
    let(:signed_in_buyer) { api_sign_in(buyer, credential_buyer) }
    let(:signed_in_seller_verify) { api_sign_in(seller_verify, credential_seller) }

    describe "GET /index" do
        context "as a seller" do
            it "list only user" do
                get(
                    "/users", 
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                
                json = JSON.parse(response.body)
                expect(json.length).to eq(1)
                expect(JSON.parse(response.body)).to eq( [{
                  "id" => seller.id,
                  "email" => seller.email,
              }] )
            end
        end

        context "as a buyer" do
          it "list only user" do
            get(
                "/users", 
                headers: {
                    "Accept" => "application/json",
                    "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                }
            )
            
            json = JSON.parse(response.body)
            expect(json.length).to eq(1)
            expect(JSON.parse(response.body)).to eq( [{
              "id" => buyer.id,
              "email" => buyer.email,
            } ])
          end
        end
    end

    describe "GET /show" do
        context "as a seller" do
        end

        context "as a buyer" do
        end
    end

    describe "PUT /update" do
      context "as a seller" do
      end

      context "as a buyer" do
      end
    end

    describe "DELETE /destroy" do
        context "as a buyer" do
            it "buyer deletes his account and then tries to delete it again" do
                delete(
                    "/users/#{buyer.id}", 
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                    }
                )
                expect(JSON.parse(response.body)['message']).to eq('User successfully deleted')

                delete(
                  "/users/#{buyer.id}", 
                  headers: {
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                  }
              )
              expect(JSON.parse(response.body)['message']).to eq('User not found')
            end

            it "buyer trying to delete another user's account" do
              delete(
                  "/users/#{seller.id}", 
                  headers: {
                      "Accept" => "application/json",
                      "Authorization" => "Bearer #{signed_in_buyer["token"]}"
                  }
              )
              expect(JSON.parse(response.body)['message']).to eq('User does not have permission')
          end
        end

        context "as a seller" do
            it "seller deleting account" do
                delete(
                    "/users/#{seller.id}", 
                    headers: {
                        "Accept" => "application/json",
                        "Authorization" => "Bearer #{signed_in_seller["token"]}"
                    }
                )
                expect(JSON.parse(response.body)['message']).to eq('User successfully deleted')
            end
        end 
    end
end