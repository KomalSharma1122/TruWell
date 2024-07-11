# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...



class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    if params[:room_id].present?
      stream_from "chat_room_#{params[:chat_room_id]}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Message.new(content: data[message], sender_id: data[sender_id], receiver_id: data[receiver_id], chat_room_id: data[chat_room_id])
    if message.save
      ActionCable.server.broadcast("chat_room_#{message['chat_room_id']}", message)
    end 
  end
end