class ChatRoomsController < ApplicationController
  before_action :authenticate_user
  
  def create 
    if current_user.has_role?(:doctor)
      render json: {status: 400, data: " ", message: "Unauthorised user"} and return unless current_user.id == chat_params[:doctor_id].to_i
      doctor = User.find_by(id: chat_params[:doctor_id])
      patient = User.find_by(id: chat_params[:patient_id])
      render json: {status: 400, data: " ", message: "you can not chat with doctor" } and return if patient.has_role?(:doctor)
      available_chat_room = ChatRoom.find_by(doctor_id: doctor.id, patient_id: patient.id)
      if available_chat_room.present?
        messages =  available_chat_room.messages
        if messages.size < 1
          render json: {status: 200, data: available_chat_room,  message: "chat room already created"}
        else 
          render json: {status: 200, data: available_chat_room.messages, message: "your messages"}
        end
      else
        patient_name = patient.first_name + " " + patient.last_name
        chat_room = ChatRoom.new(name: "chat #{ChatRoom.last.id+1}", doctor_id: doctor.id, patient_id: patient.id, status: :active )
        if chat_room.save
          render json: {status: 200, data: chat_room, patient: patient_name,  message: " You can now chat with #{patient_name}"}
        else 
          render json: {status:400, data: " ", message: "chat_room.errors.full_messages"}
        end 
      end
    elsif current_user.has_role?(:patient)
      render json: {status: 400, data: " ", message: "Unauthorised user"} and return unless current_user.id == chat_params[:patient_id].to_i
      doctor = User.find_by(id: chat_params[:doctor_id])
      patient = User.find_by(id: chat_params[:patient_id])
      render json: {status: 400, data: " ", message: "you can not chat with patient" } and return if doctor.has_role?(:patient)
      available_chat_room = ChatRoom.find_by(doctor_id: doctor.id, patient_id: patient.id)
      if available_chat_room.present?
        # messages = available_chat_room.messages
        # if messages.size < 1
          render json: {status: 200, data: available_chat_room,  message: "chat room already created"}
        # else 
          # render json: {status: 200, data: available_chat_room.messages, message: "your messages"}
        # end 
      else 
        doctor_name = "Dr."  + " " + doctor.first_name + " " + patient.last_name
        chat_room = ChatRoom.new(name: "chat #{ChatRoom.last.id+1}", doctor_id: doctor.id, patient_id: patient.id, status: :active)
        if chat_room.save 
          render json: {status: 200, data: chat_room, doctor: doctor_name, message: " You can now chat with #{doctor_name}"}
        else 
          render json: {status:400, data: " ", message: "chat_room.errors.full_messages"}
        end 
      end 
    else 
      render json: {status: 400, data: " ", message: "Invalid Role"}
    end 
  end

  def index
    if current_user.has_role?(:doctor) 
      chat_rooms = ChatRoom.where(doctor_id: current_user.id)
      chat_rooms_with_message = []
      chat_rooms.each do |chat|
        messages = Message.where(chat_room_id: chat.id) 
        patient = User.find_by(id: chat.patient_id)
        patient_name =  patient.first_name + " " + patient.last_name
        if messages.present?
          chat_rooms_with_message << {
            chat_room: chat,
            patient_name: patient_name,
            message: chat.messages.last
        }
        end
      end 
        render json: {status: 200, data: chat_rooms_with_message.sort_by{|hash| hash[:message][:created_at]}, messages: "Your chats"}
    elsif current_user.has_role?(:patient) 
      chat_rooms = ChatRoom.where(patient_id: current_user.id)
      chat_rooms_with_message = []
      chat_rooms.each do |chat|
        messages = Message.where(chat_room_id: chat.id) 
        doctor = User.find_by(id: chat.doctor_id)
        doctor_name =  doctor.first_name + " " + doctor.last_name
        doctor_id = chat.doctor_id
        if messages.present?
          chat_rooms_with_message << {
            chat_room: chat,
            doctor_name: doctor_name,
            message: chat.messages.last,
            speciality: DoctorInformation.find_by(user_id: doctor_id).specialization
          }
        end
      end 
        render json: {status: 200, data: chat_rooms_with_message, messages: "Your chats"}
    else
      render json: {status: 400, data: " ", message: "Invalid Role"}
    end 
  end 

  def new_chats
    if current_user.has_role?(:doctor)
      appointments = Appointment.where(doctor_id: current_user.id)
      chat_with = []
      appointments.each do |appointment|
        chat_with << {
          patient_id: appointment.patient_id,
          patient_name: User.find_by(id: appointment.patient_id).first_name + " " + User.find_by(id: appointment.patient_id).last_name
        }
      end 
      render json: {status: 200, data: chat_with.uniq, message: "chats" }
    elsif current_user.has_role?(:patient)
      chat_with = [] 
      users = User.with_role(:doctor)
      users.each do |user|
        chat_with << {
          doctor_id: user.id,
          doctor_name: "Dr." +  " " + user.first_name + " " + user.last_name,
          doctor_specialisation: user.doctor_information.specialization
        }
      end
      render json: {status: 200, data: chat_with, message: "chats" }
    else
      render json: {status: 400, data: " ", message: "Invalid role"}
    end 
  end 

  def favourite_chats
    if current_user.has_role?(:doctor)
      favorite_chats = ChatRoom.where(doctor_id: current_user.id, status: "favourite") 
      if favorite_chats.size > 0 
        render json: {data: 200, data: favorite_chats, message: "favourite chats"}
      else 
        render json: {data: 200, data: " ", message: " No favourite chats"}
      end 
    elsif current_user.has_role?(:patient)
      favorite_chats = ChatRoom.where(patient_id: current_user.id, status: "favourite") 
      if favorite_chats.size > 0 
        render json: {data: 200, data: favorite_chats, message: "favourite chats"}
      else 
        render json: {data: 200, data: " ", message: " No favourite chats"}
      end 
    else
      render json: {status: 400, data: " ", message: "Invalid role"}
    end 
  end 

  def add_to_favourites
    chat_room = ChatRoom.find_by(id: params[:id])
    render json: {status:400, data: " ", message: "Chat Room not found"} and return if chat_room.nil?
    if current_user.has_role?(:doctor)
      render json: {status:400, data: " ", message: "You can not add this chat to favourite"} and return unless current_user.id == chat_room.doctor_id
      render json: {status:200, data: " ", message: "Already Added to favourites "} and return if chat_room.status == "favourite"
      chat_room.update(status: :favourite)
      render json: {status:200, data: chat_room, message: "Added to Favourites"}
    elsif current_user.has_role?(:patient)
      render json: {status:400, data: " ", message: "You can not add this chat to favourite"} and return unless current_user.id == chat_room.patient_id
      render json: {status:200, data: " ", message: "Already Added to favourites "} and return if chat_room.status == "favourite"
      chat_room.update(status: :favourite)
      render json: {status:200, data: chat_room, message: "Added to Favourites"}
    else 
      render json: {status: 400, data: " ", message: "Invalid role"}
    end 
  end 

  def delete_chat
    chat_room = ChatRoom.find_by(id: params[:id])
    render json: {status:400, data: " ", message: "Chat Room not found"} and return if chat_room.nil?
    if current_user.has_role?(:doctor)
      chat_room = ChatRoom.find_by(id: params[:id])
      render json: {status:400, data: " ", message: "You can not delete this chat "} and return unless current_user.id == chat_room.doctor_id
      chat_room.destroy
      render json: {status: 200, data: " ", message: "Chat deleted succesfully" }
    elsif current_user.has_role?(:patient)
      render json: {status:400, data: " ", message: "You can not delete this chat "} and return unless current_user.id == chat_room.patient_id
      chat_room.destroy
      render json: {status: 200, data: " ", message: "Chat deleted succesfully" }
    else
      render json: {status: 400, data: " ", message: "Invalid role"}
    end 
  end 


  def chat_params
    params.require(:chat).permit(:name, :doctor_id, :patient_id)
  end 
end










 

#   doctor_name = "Dr."  + " " + doctor.first_name + " " + patient.last_name
#   chat_room = ChatRoom.new(name: "chat #{ChatRoom.last.id+1}", doctor_id: doctor.id, patient_id: patient.id, status: :active )
#   if chat_room.save 
#     render json: {status: 200, data: chat_room, doctor: doctor_name, message: " You can now chat with #{doctor_name}"}
#   else 
#     render json: {status:400, data: " ", message: "chat_room.errors.full_messages"}
#   end

#   patient_name = patient.first_name + " " + patient.last_name
#   chat_room = ChatRoom.new(name: "chat #{ChatRoom.last.id+1}", doctor_id: doctor.id, patient_id: patient.id, status: :active )
#   if chat_room.save
#     render json: {status: 200, data: chat_room, message: " You can now chat with #{patient_name}"}
#   else
#     render json: {status:400, data: " ", message: "chat_room.errors.full_messages"}
#   end