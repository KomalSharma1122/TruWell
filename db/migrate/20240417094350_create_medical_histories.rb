class CreateMedicalHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :medical_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :disease_name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end


