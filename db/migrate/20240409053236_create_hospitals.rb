class CreateHospitals < ActiveRecord::Migration[7.1]
  def change
    create_table :hospitals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.string :pincode

      t.timestamps
    end
  end
end
