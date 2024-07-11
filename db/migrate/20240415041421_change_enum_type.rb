class ChangeEnumType < ActiveRecord::Migration[7.1]
  def change
    # change_column :time_slots, :status, :integer
    # change_column :appointments, :status, :integer

    #Ex:- change_column("admin_users", "email", :string, :limit =>25)

    #Ex:- change_column("admin_users", "email", :string, :limit =>25)


    remove_column :time_slots, :status
    remove_column :appointments, :status


    add_column :time_slots, :status, :integer
    add_column :appointments, :status, :integer
    

  end
end
