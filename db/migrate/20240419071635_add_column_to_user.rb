class AddColumnToUser < ActiveRecord::Migration[7.1]
  def up
    add_attachment :users, :profile_pic
  end

  def down
    remove_attachment :users, :profile_pic
  end
end     