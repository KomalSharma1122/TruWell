class UpdateMedicalHistory
  include Sidekiq::Job

  def perform(params)
    medical_history_id = params["medical_history_id"]
    medical_history = MedicalHistory.find_by(id: medical_history_id)
    medical_history.update(status: "past")
  end
end