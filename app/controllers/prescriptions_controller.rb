class PrescriptionsController < ApplicationController
  before_action :authenticate_user
  
  def create
    render json: {status: 400, data: " ", message: "Unauthorised user"} and return unless current_user.has_role?(:doctor)
    if params[:prescription].present?
      appointment = Appointment.find_by(id: prescription_params[:appointment_id])
      doctor = appointment.doctor
      patient = appointment.patient
      render json: {status: 400, data: " ", message: "you can not provide prescription at this time"} and return unless appointment.status == "completed"
      render json: {status: 400, data: " ", message: "you can not provide prescription for this"} and return unless (current_user.id == doctor.id)
      if prescription_params[:prescription_type] == "prescription"
        created_prescription = Prescription.where(appointment_id: appointment.id, prescription_type: "prescription")
        render json: {status: 400, data: " ", message: "prescription already created"} and return unless created_prescription.size==0
      elsif prescription_params[:prescription_type] == "sick_note"
        created_sick_note = Prescription.where(appointment_id: appointment.id, prescription_type: "sick_note")
        render json: {status: 400, data: " ", message: "sick note already created"} and return unless created_sick_note.size==0
      else
        render json: {status: 400, data: " ", message: "Invalid prescription type"}
      end       
      if params[:instructions].present?
        prescription = Prescription.new(prescription_params.merge(instructions: params[:instructions]))
      else 
        prescription = Prescription.new(prescription_params)
      end
      render json: {status: 400, data: " ", message: prescription.errors.full_messages} and return unless prescription.save
      render json: {status:200, data: prescription, patient_name: patient.first_name, message: "prescription created successfully"}
    else 
      render json: {status: 400, data: " ", message: "Required parameters are missing"}
    end 
  end 

  def index
    if current_user.has_role?(:patient)
      patient_id = current_user.id
      if params[:type] == "prescription"
        received_prescriptions = []
        appointments = Appointment.where(patient_id: patient_id)
        appointments.each do |i|
          if i.prescriptions.present?
          received_prescriptions << i.prescriptions.where(prescription_type: "prescription")
          else 
            next
          end 
        end 
        render json: {status: 200, data: "", message: "no prescription received by you"} and return if received_prescriptions.size == 0
        render json: {status: 200, data: received_prescriptions.flatten, message: "these are the received prescription"}
      elsif params[:type] == "sick_note"

        received_sick_notes = []
        appointments = Appointment.where(patient_id: patient_id)
        appointments.each do |i|
          if i.prescriptions.present?
          received_sick_notes << i.prescriptions.where(prescription_type: "sick_note")
          else 
            next
          end 
        end 
        render json: {status: 200, data: "", message: "no sick note received by you"} and return if received_sick_notes.size == 0
        render json: {status: 200, data: received_sick_notes.flatten, message: "these are the received prescription"}
      else 
        render json: {status: 400, data: " ", message: "Invalid type"}
      end 

    elsif current_user.has_role?(:doctor)
      doctor_id = current_user.id
      provided_prescriptions = []
      appointments = Appointment.where(doctor_id: doctor_id)
      appointments.each do |i|
        if i.prescriptions.present?
          patient_id = i.patient_id     
          patient_name = User.find(patient_id).first_name
          patient = {patient_name: patient_name}
          # provided_prescriptions << i.prescriptions

          # i.prescriptions.each do |p|
          #   p.merge(patient)
          # end

        provided_prescriptions << {
          prescription: i.prescriptions,
          patient_name: User.find(patient_id).first_name
        }
        # # 
        # patient = i.patient
        # provided_prescriptions << patient.first_name
        else 
          next
        end 
      end 
      render json: {status: 200, data: [], message: "no prescription provided by you"} and return if provided_prescriptions.size == 0
      render json: {status: 200, data: provided_prescriptions.flatten, message: "these are the provided prescription by you"}
    else
      render json: {status: 400, data: " ", message: "Invalid role"}
    end 
  end 

  def update 
    if current_user.has_role?(:doctor)
      current_doctor_id =  current_user.id
      prescription = Prescription.find_by(id:params[:id]) 
      render json: {status: 400, data: "", message: 'Prescription not found'} and return if prescription.nil?
      appointment = Appointment.find_by(id: prescription.appointment_id)
      doctor_id = appointment.doctor_id
      render json: {status: 400, data: " ", message: "Unauthorised doctor"} and return unless (current_doctor_id  == doctor_id)
      if params[:update_prescription].present?
        prescription.update(update_prescription)
        render json: {status: 200, data: prescription, message: "Prescription updated successfully"}
      else
        render json: {status: 400, data: " ", message: "Required Parameters are missing"}
      end 
    elsif current_user.has_role?(:patient)
      render json: {status: 400, data: " ", message: "You are not authorised"}
    else
      render json: {status: 400, data: " ", message: "Invalid role"}
    end 
  end 

  def destroy
    render json: {status: 400, data: " ", message: "You are not authorised"} and return if current_user.has_role?(:patient)
    current_doctor_id =  current_user.id
    prescription = Prescription.find_by(id:params[:id])
    render json: {status: 400, data: "", message: 'Prescription not found'} and return if prescription.nil?
    appointment = Appointment.find_by(id: prescription.appointment_id)
    doctor_id = appointment.doctor_id
    render json: {status: 400, data: " ", message: "Unauthorised doctor"} and return unless (current_doctor_id  == doctor_id)
    prescription.destroy
    # render json: {status: 400, data: prescription, message: "error while deleting prescription"} and return if prescription.present?
    render json: {status: 200, data: prescription, message: "Prescription deleted successfully"} 
  end 

  def update_prescription
    params.require(:update_prescription).permit(:title, :dosage, :quantity, :medicine, :instructions)
  end 

  def prescription_params
    params.require(:prescription).permit(:appointment_id, :title, :prescription_type, :dosage, :quantity, :medicine)
  end 

end




