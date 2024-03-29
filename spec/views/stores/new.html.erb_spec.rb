require 'rails_helper'

RSpec.describe "stores/new", type: :view do
  before(:each) do
    @user = login_user
    
    assign(:store, Store.new(
      name: "MyString", user: @user
    ))
  end

  it "renders new store form" do
    render

    assert_select "form[action=?][method=?]", stores_path, "post" do

      assert_select "input[name=?]", "store[name]"
    end
  end
end
