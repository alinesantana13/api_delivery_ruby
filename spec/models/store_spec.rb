require 'rails_helper'

RSpec.describe Store, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_length_of(:name).is_at_least(3) }
    it { should belong_to(:user) }
  end

  describe "belongs_to" do
    let(:seller) {
      User.create!(
        email: "seller@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :seller
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

    it "should not belong to admin users" do
      store = Store.create(name: "store", user: admin)

      expect(store.errors.full_messages).to eq ["User must exist"]
    end
  end
end
