class AddColumnToAppointment < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :start_time, :datetime
    add_column :appointments, :end_time, :datetime

    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
