class Message < ApplicationRecord

  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'

  validates :content, :sender_id, :receiver_id, presence: true

  enum status: {read: 0, unread: 1}

  # after_create_commit { MessageBroadcastJob.perform_later self }

  # after_create_commit  {ActionCable.server.broadcast("chat_room_#{message['chat_room_id']}", message)}

end
