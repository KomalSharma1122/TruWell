class ChangeColumn < ActiveRecord::Migration[7.1]
  def change
    change_column :doctor_availabilities, :start_time, :time
    change_column :doctor_availabilities, :end_time, :time


    #Ex:- change_column("admin_users", "email", :string, :limit =>25)
  end
end
