require 'rails_helper'

RSpec.describe "stores/new", type: :view do
  let(:admin) {
      User.create!(
        email: "admin@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
      )
  }
  
  before(:each) do
    @user = login_user
    
    assign(:store, Store.new(
      name: "MyString", user: @user
    ))

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

  it "renders new store form" do
    allow(view).to receive(:current_user).and_return(admin)
    render

    assert_select "form[action=?][method=?]", stores_path, "post" do

      assert_select "input[name=?]", "store[name]"
    end

    assert_select "select[name=?]", "store[user_id]"
  end
end
