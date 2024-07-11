class CreateUserAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :user_addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :line1
      t.string :line2
      t.string :city
      t.integer :pincode
      t.timestamps
    end
  end
end
