class MessagesController < ApplicationController
  before_action :authenticate_user

  def create
    chat_room = ChatRoom.find_by(id: message_params[:chat_room_id])
    if current_user.has_role?(:doctor)  
      render json: {status: 400, data: " ", message: "Chat room not found"} and return unless chat_room.present?
      render json: {status: 400, data: " ", message: "you are not authorised"} and return unless message_params[:sender_id].to_i == current_user.id && message_params[:receiver_id].to_i == chat_room.patient_id
      message = Message.new(message_params.merge(status: :unread))
      if message.save 
        # ActionCable.server.broadcast("chat_room_#{message.chat_room_id}", message)
        render json: {status:200, data: message, message: "Message sent"}
      else
        render json: {status:200, data: " ", message: message.errors.full_messages}
      end 
    elsif current_user.has_role?(:patient)
      render json: {status: 400, data: " ", message: "Chat room not found"} and return unless chat_room.present?
      render json: {status: 400, data: " ", message: "you are not authorised"} and return unless message_params[:sender_id].to_i == current_user.id && message_params[:receiver_id].to_i == chat_room.doctor_id
      message = Message.new(message_params.merge(status: "unread"))
      if message.save 
        render json: {status:200, data: message, message: "Message sent"}
      else
        render json: {status:200, data: " ", message: message.errors.full_messages}
      end
    else
      render json: {status:400, data: " ", message: "Invalid role"}
    end
  end 

  def index
    chat_room = ChatRoom.find_by(id: params[:chat_room_id])
    if current_user.has_role?(:doctor)
      render json: {status: 400, data: " ", message: "You cant get message of this chat"} and return unless current_user.id == chat_room.doctor_id
      messages = chat_room.messages
      if messages.size > 0 
        render json: {status:200, data: messages, messages: "All messages"}
      else
        render json: {status: 200, data: " ", message: "No messages yet"}
      end 
    elsif current_user.has_role?(:patient)
      render json: {status: 400, data: " ", message: "You cant get message of this chat"} and return unless current_user.id == chat_room.patient_id
      messages = chat_room.messages
      if messages.size > 0
        render json: {status:200, data: messages, messages: "All messages"}
      else
        render json: {status: 200, data: " ", message: "No messages yet"}
      end 
    else 
      render json: {status:400, data: " ", message: "Invalid role"}
    end 
  end 

  def delete 
    message = Message.find_by(id: params[:id])
    render json: {status:400, data: " ", message: "Message no found"} and return unless message.present?
    if current_user.id == message.sender_id 
      message.destroy
      render json: {status: 200, data: " ", message: "Message deleted successfully"}
    else 
      render json: {status: 400, data: " ", message: "You can not delete this message"}
    end 
  end 

  def hello 
    ActionCable.server.broadcast "ChatRoomChannel", "hello Hardik"
  end 

  def message_params
    params.require(:message).permit(:content, :chat_room_id, :sender_id, :receiver_id)
  end 
end

