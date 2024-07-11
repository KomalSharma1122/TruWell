class MessageBroadcastJob < ApplicationJob
  # include Sidekiq::Job

  def perform(message)
    ActionCable.server.broadcast("chat_room_#{message['chat_room_id']}", message)
  end
end
