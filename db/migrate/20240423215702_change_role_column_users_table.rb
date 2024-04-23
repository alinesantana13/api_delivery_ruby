class ChangeRoleColumnUsersTable < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :role, :integer, null: false
  end
end
