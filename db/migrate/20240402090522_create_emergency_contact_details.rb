class CreateEmergencyContactDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :emergency_contact_details do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :phone_no
      t.string :relation

      t.timestamps
    end
  end
end
