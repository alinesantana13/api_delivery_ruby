require 'rails_helper'

RSpec.describe "stores/edit", type: :view do
  let(:user){FactoryBot.create(:user, :seller)}
  let(:store) {
    Store.create!(
      name: "MyString", user: user
    )
  }

  let(:admin) { FactoryBot.create(:user, :admin) }

  before(:each) do
    assign(:store, store)
    @sellers = [
      FactoryBot.create(:user, :seller), 
      FactoryBot.create(:user, :seller)]
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
