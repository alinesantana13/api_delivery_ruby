require 'rails_helper'

RSpec.describe "stores/edit", type: :view do
  let(:store) {
    Store.create!(
      name: "MyString", user: @user = login_user
    )
  }

  let(:admin) {
      User.create!(
        email: "admin@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
      )
  }

  before(:each) do
    assign(:store, store)
    @sellers = [
      User.create(email: "seller1@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :seller), 
      User.create(
        email: "seller2@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :seller)]
    assign(:sellers, @sellers)
  end

  it "renders the edit store form" do
    allow(view).to receive(:current_user).and_return(admin)
    render

    assert_select "form[action=?][method=?]", store_path(store), "post" do

      assert_select "input[name=?]", "store[name]"
    end

    assert_select "select[name=?]", "store[user_id]"
  end
end
