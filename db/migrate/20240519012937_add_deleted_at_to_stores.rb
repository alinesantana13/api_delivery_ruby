class AddDeletedAtToStores < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :deleted_at_timestamp, :integer
  end
end
