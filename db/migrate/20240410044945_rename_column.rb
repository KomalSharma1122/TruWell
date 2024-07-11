class RenameColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :doctor_availabilities, :start_date_time, :start_time
    rename_column :doctor_availabilities, :end_date_time, :end_time
    
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
