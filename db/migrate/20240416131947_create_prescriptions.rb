class CreatePrescriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :prescriptions do |t|
      t.references :appointment, null: false, foreign_key: true
      t.string :title
      t.string :type
      t.integer :dosage
      t.integer :quantity
      t.string :medicine

      t.timestamps
    end
  end
end
