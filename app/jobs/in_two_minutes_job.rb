class InTwoMinutesJob
  include Sidekiq::Job

  def perform(name, time )
    time.times do
      puts " Helllooooo #{name}"
    end 
  end

end 