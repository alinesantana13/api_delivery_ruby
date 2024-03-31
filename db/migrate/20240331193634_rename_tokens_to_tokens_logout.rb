class RenameTokensToTokensLogout < ActiveRecord::Migration[7.1]
  def change
    rename_table :tokens, :tokens_logout
  end
end
