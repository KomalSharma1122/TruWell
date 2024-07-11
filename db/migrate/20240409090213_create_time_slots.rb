class CreateTimeSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :time_slots do |t|
      t.references :doctor_availability, null: false, foreign_key: true
      t.time :start_time
      t.time :end_time
      t.string :status
      t.bigint :user_id


      t.timestamps
    end
  end
end
