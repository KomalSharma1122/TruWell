class CreateDoctorAvailabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :doctor_availabilities do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :start_date_time
      t.datetime :end_date_time
      t.integer :duration
      t.integer :status

      t.timestamps
    end
  end
end
