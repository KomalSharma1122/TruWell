class FirstJob
  include Sidekiq::Job

  def perform(name)
    # user = User.last
    # user.update(first_name: "Aamena")
    puts "Hiii my name is #{name}, what is your name "
  end 
end 