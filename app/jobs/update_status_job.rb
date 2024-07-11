class UpdateStatusJob
  include Sidekiq::Job

  def perform(params)
    appointment_id = params["appointment_id"]
    appointment = Appointment.find_by(id: appointment_id)
    appointment.update(status: "completed")
  end
end