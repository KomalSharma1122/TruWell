
class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    
    if params[:chat_room_id].present?
      puts "__________________________________You are connected to the channel __________________________________________________"
      stream_from "chat_room_#{params[:chat_room_id]}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    
    puts "-----------------------------------Data is #{data}-----------------------------------------" 
    puts "-----------------------------------params is #{params}-------------------------------------"

    # message_data = JSON.parse(data)
    # message_data = data


    # puts "-----------------------------------Message data is #{message_data}-------------------------"

    message = Message.new(content: data['content'], sender_id: data['sender_id'], receiver_id: data['receiver_id'], chat_room_id: data['chat_room_id'])
    # message.save
  
    if message.save
      puts "--------------------------- BROADCASTING THE MESSAGE -----------------------------"
      ActionCable.server.broadcast("chat_room_#{message['chat_room_id']}", message)
      puts "---------------------------  MESSAGE  IS BROADCASTED-----------------------------"

    else 
      puts "errors are ---------------------------#{message.errors.full_messages}"
    end

      puts "--------------------------- BROADCASTING THE MESSAGE -----------------------------"
  end
end

# ("content: 'hii ii' chat_room_id: 20 sender_id: 104 receiver_id: 97")