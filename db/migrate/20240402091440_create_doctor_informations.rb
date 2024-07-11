class CreateDoctorInformations < ActiveRecord::Migration[7.1]
  def change
    create_table :doctor_informations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :language
      t.string :specialization
      t.string :about
      t.integer :charges

      t.timestamps
    end
  end
end
