class RenameTokensToTokenLogouts < ActiveRecord::Migration[7.1]
  def change
    rename_table :tokens_logout, :token_logouts
  end
end
