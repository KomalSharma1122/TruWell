class AppointmentsController < ApplicationController
  before_action :authenticate_user

  def create
    # @user = User.find_by(token: request.headers["HTTP_AUTH_TOKEN"])
    if current_user.has_role?(:patient)  
      time_slot = TimeSlot.find_by(id: appointment_params[:time_slot_id])
      render json: {status: 400, data: " ", message: "Invalid Slot"} and return if time_slot.nil?
      render json: {status: 400, data: " ", message:"Slot already booked"} and return if time_slot.status == "booked"
      slot_start_time = time_slot.start_time
      slot_end_time = time_slot.end_time
      start_time = appointment_params[:start_time]
      end_time = appointment_params[:end_time]

      # (start_time != slot_start_time || end_time != slot_end_time )
      render json: {status: 400, data: " ", message: "Time not valid"} and return if (slot_start_time != start_time || slot_end_time != end_time )
      appointment = Appointment.new(appointment_params.merge(status: "upcoming"))
      render json: {status: 400, data: "", message: appointment.errors.full_messages} and return unless appointment.save 

      UpdateStatusJob.perform_at(appointment.end_time + 1.minute, {"appointment_id" => appointment.id})


      ConfirmedAppointmentMail.appointment_email.deliver_now


      booked_slot = TimeSlot.find_by(id: appointment_params[:time_slot_id])
      booked_slot.update(status: "booked")
      render json: {status:200, data: appointment, message: "Appointment created successfully"}
    else 
      render json: {status: 400, data: "", message: "Unauthorised role"} 
    end
  end

  def index
    if current_user.has_role?(:patient)
      patient_id = current_user.id
      if params[:status] == "upcoming"
        # .where('start_time  > ?', DateTime.now.utc)
        upcoming_appoitments = Appointment.where(status: "upcoming", patient_id: patient_id)
        render json: {status:200, data: "", message: "No upcoming appointments"} and return unless upcoming_appoitments.present?
        upcoming_appointment_details = []
        upcoming_appoitments.each do |i|
          doctor = User.find_by(id: i.doctor_id)
          upcoming_appointment_details << {   
            appointment_id: i.id,
            appointment_time: i.start_time,
            doctor: doctor,
            hospital: doctor.hospital,
            doctor_info: doctor.doctor_information
          }
        end 
        render json: {status:200, data: upcoming_appointment_details.sort_by {|hash| hash[:appointment_time] }, messages: "Upcoming appointments"}
      elsif params[:status] == "completed"
        completed_appointments = Appointment.where('end_time < ?', DateTime.now.utc).where(patient_id: patient_id, status: "completed") 
        render json: {status:200, data: "", message: "No completed appointments"} and return unless completed_appointments.present?
        # completed_appointments.each do |i|
        #   i.update(status: "completed")
        # end 
        completed_appointment_details = []
        completed_appointments.each do |i|
          doctor =  User.find_by(id: i.doctor_id)
          completed_appointment_details << {
            appointment_id: i.id,
            appointment_time: i.start_time,
            doctor: doctor,
            hospital: doctor.hospital,
            doctor_info: doctor.doctor_information
          }
        end 
        render json: {status:200, data: completed_appointment_details.sort_by { |hash| hash[:appointment_time] }, messages: "Completed appointments"}
      else
        render json: {status:400, data: "", message: "Invalid Status"}
      end 
    elsif current_user.has_role?(:doctor)
      doctor_id = current_user.id
      if params[:status] == "upcoming"
        upcoming_appoitments = Appointment.where(status: "upcoming", doctor_id: doctor_id).where('start_time > ?', DateTime.now.utc )
        render json: {status:200, data: [], message: "No upcoming appointments"} and return unless upcoming_appoitments.present?
        upcoming_appointment_details = []
        upcoming_appoitments.each do |i|
          patient =  User.find_by(id: i.patient_id)
          upcoming_appointment_details << {
            appointment_id: i.id,
            appointment_status: i.status,
            appointment_date: i.start_time,
            first_name: patient.first_name,
            phone_no: patient.phone_no,
            charges: current_user.doctor_information.charges
          }
          # patient_details << patient.first_name
          # patient_details << patient.phone_no
          # patient_details << @user.doctor_information.charges
          # patient_details << i
         
        end 
        render json: {status: 200, data: upcoming_appointment_details, message: "Upcoming slots"}
      elsif params[:status] == "completed"  
        completed_appointments = Appointment.where('end_time < ?', DateTime.now.utc).where(doctor_id: doctor_id, status: "completed")
        render json: {status:200, data: [], message: "No completed appointments"} and return unless completed_appointments.present?
        completed_appointment_details = []
        completed_appointments.each do |i|
          patient =  User.find_by(id: i.patient_id)
          completed_appointment_details << {
            appointment_id: i.id,
            appointment_status: i.status,
            appointment_date: i.start_time,
            first_name: patient.first_name,
            phone_no: patient.phone_no,
            charges: current_user.doctor_information.charges
          }
        end 
        render json: {status: 200, data: completed_appointment_details, message: "Completed slots"}
      else
        render json: {status:400, data: "", message: "Invalid Status"}
      end
    else 
      render json: {status:400, data: "", message: "Role not find"}
    end 
  end 

  def destroy
  end 


  def appointment_params
    params.require(:appointment).permit(:time_slot_id, :patient_id, :doctor_id, :start_time, :end_time)
  end 
end




 # def update
  #   # user = User.find_by(token: request.headers["HTTP_AUTH_TOKEN"])
  #   render json: {status:404, message: "invalid role"} and return unless current_user.has_role?(:doctor)
  
  #   appointment = Appointment.find_by(id: params[:id])
  #   render json: {status: 400, data: "", message: "appointment not found"} and return if appointment.nil?
  #   start_time = appointment.start_time
  #   end_time = appointment.end_time
    
  #   render json: {status: 400, data: "", message: "you can not update this appointment at this time"} and return unless (DateTime.now.utc > start_time && DateTime.now.utc < end_time)
  #   appointment.update(status: "completed")

  #   render json: {status: 200, data: "", message: "Appointment completed"}
  # end 