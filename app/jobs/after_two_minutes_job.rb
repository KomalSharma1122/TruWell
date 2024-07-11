class AfterTwoMinutesJob
  include Sidekiq::Job

  def perform (name)
    puts "#{name} from after two minute job class"
  end 

end