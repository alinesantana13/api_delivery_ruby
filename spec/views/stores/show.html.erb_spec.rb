require 'rails_helper'

RSpec.describe "stores/show", type: :view do
  before(:each) do
    @user = login_user

    assign(:store, Store.create!(
      name: "Name", user: @user
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
