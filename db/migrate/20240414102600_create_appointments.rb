class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.references :time_slot, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.string :status
      t.timestamps
    end
    # add_foreign_key :appointments, :users, column: :patient_id
    # add_foreign_key :appointments, :users, column: :doctor_id
  end
end
