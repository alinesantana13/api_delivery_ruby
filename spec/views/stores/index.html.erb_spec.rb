require 'rails_helper'

RSpec.describe "stores/index", type: :view do
  before(:each) do
    @user = login_user
    
    assign(:stores, [
      Store.create!(
        name: "Name", user: @user
      ),
      Store.create!(
        name: "Name", user: @user
      )
    ])
  end

  it "renders a list of stores" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
  end
end
