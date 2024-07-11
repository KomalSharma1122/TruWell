class MedicalHistoriesController < ApplicationController
  before_action :authenticate_user

  def create
    render json: {status: 400, data: " ", message: "You are not authorised"} and return if current_user.has_role?(:doctor)
    render json: {status: 400, data: " ", message: "Required parameter missing"} and return unless params[:history].present?
    if params[:end_date].present?
      medical_history = MedicalHistory.new(history_params.merge(end_date: params[:end_date]))
      if params[:end_date] < DateTime.now.utc 
        medical_history.status = "past"
      else 
        medical_history.status = "active"
        UpdateMedicalHistory.perform_at((medical_history.end_date + 1.day).to_time, {"medical_history_id" => medical_history.id})
      end
    else 
      medical_history = MedicalHistory.new(history_params.merge(status: "active"))
    end 
    render json: {status: 400, data: "", message: medical_history.errors.full_messages} and return unless medical_history.save
    render json: {status:200, data: medical_history , message: "medical history created successfully" }
  end 

  def index
    if current_user.has_role?(:patient)
      if params[:status] == "active"
        active_medical_histories = MedicalHistory.where(user_id: current_user.id, status: "active")
        render json: {status: 200, data: "", message: "no medical history present"} and return if active_medical_histories.size == 0
        render json: {status: 200, data: active_medical_histories, message: "your medical history"}
      elsif params[:status] == "past"
        past_medical_histories = MedicalHistory.where(user_id: current_user.id, status: "past")
        render json: {status: 200, data: "", message: "no medical history present"} and return if past_medical_histories.size == 0
        render json: {status: 200, data: past_medical_histories, message: "your medical history"}
      else 
        render json: {status: 400, data: " ", message: "invalid status"}
      end 
    elsif current_user.has_role?(:doctor)
      if params[:appointment_id].present? 
        appointment = Appointment.find_by(id: params[:appointment_id])
        patient_id = appointment.patient_id

        patient_name = User.find_by(id: patient_id).first_name

        medical_histories = MedicalHistory.where(user_id: patient_id)
        render json: {status: 200, data: [], name: patient_name, message: "no medical history present"} and return if medical_histories.size == 0
        render json: {status: 200, data: medical_histories, name: patient_name, message: "Medical History of patient"}
      else 
        render json: {status: 400, data: " ", message: "appointment id needed"}
      end 
    else
      render json: {status: 400, data: " ", message: "Invalid role"}
    end 
  end 
  def history_params
    params.require(:history).permit(:user_id, :disease_name, :start_date)
  end 
end