class RemoveColumnConfirmPassword < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :confirm_password
  end
end
