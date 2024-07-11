class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_no
      t.string :password
      t.string :confirm_password
      t.date :dob
      t.integer :gender
      t.integer :status
      t.string :password_digest
      t.string :token

      t.timestamps
    end
  end
end
