class ChangeColumnType < ActiveRecord::Migration[7.1]
  def change
    remove_column :doctor_availabilities, :start_time
    remove_column :doctor_availabilities, :end_time


    add_column :doctor_availabilities, :start_time, :datetime
    add_column :doctor_availabilities, :end_time, :datetime
  end 
end
