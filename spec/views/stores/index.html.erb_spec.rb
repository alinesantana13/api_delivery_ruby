require 'rails_helper'

RSpec.describe "stores/index", type: :view do
  let(:user){FactoryBot.create(:user, :seller)}
  before(:each) do
    stores = [
      Store.create!(name: "Name", user: user),
      Store.create!(name: "Name", user: user)
    ]

    Kaminari.config.default_per_page = 1
    @stores = Kaminari.paginate_array(stores).page(1)

    assign(:stores, @stores)
  end

  it "renders a list of stores" do
    render

    assert_select '.container_stores_store', count: 1

    assert_select '.container_stores_store', text: /Name/, count: 1
  end
end
