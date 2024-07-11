class AddForDateToDoctorAvailabily < ActiveRecord::Migration[7.1]
  def change
    add_column :doctor_availabilities, :for_date, :date
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
