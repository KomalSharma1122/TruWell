class SecondJob
  include Sidekiq::Job

  def perform
    user = User.last
    user.update(first_name: "shubham")
    puts "data updated"
  end 
end 