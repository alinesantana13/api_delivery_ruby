require 'rails_helper'

RSpec.describe "stores/new", type: :view do
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:user){ FactoryBot.create(:user, :seller) }

  before(:each) do
    assign(:store, Store.new(
      name: "MyString", user: user
    ))

    @sellers = [
      FactoryBot.create(:user, :seller), 
      FactoryBot.create(:user, :seller)]
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
