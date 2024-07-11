class ChangeColumnNameOfChatRoom < ActiveRecord::Migration[7.1]
  def change
    rename_column :chat_rooms, :sender_id, :doctor_id
    rename_column :chat_rooms, :receiver_id, :patient_id
    
  end
end
