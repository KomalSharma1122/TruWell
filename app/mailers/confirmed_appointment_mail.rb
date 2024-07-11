class ConfirmedAppointmentMail < ActionMailer::Base
  default from: 'komalchomal1@gmail.com'
  # layout "mailer"

  def appointment_email
    mail(to: 'skosha2001@gmail.com', subject: 'Welcome Mail')
  end 
end 
