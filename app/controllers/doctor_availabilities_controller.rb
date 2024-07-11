class DoctorAvailabilitiesController < ApplicationController
  before_action :authenticate_user
  
  def create
    user = User.find_by(id: availability_params[:user_id])
    render json: {status:404, message: "user not found"} and return if user.nil?
    render json: {status:404, message: "invalid role"} and return unless user.has_role?(:doctor)
    for_date = availability_params[:for_date]  
    dates = for_date.split(",")
    date_range = dates[0].to_date..dates[1].to_date
    availability_present = false
    date_range.each do |d|
    
      
      start_date = d.to_datetime + availability_params[:start_time].to_datetime.hour.hour + availability_params[:start_time].to_datetime.minute.minutes

      end_date =   d.to_datetime + availability_params[:end_time].to_datetime.hour.hour + availability_params[:end_time].to_datetime.minute.minutes
      availabilities = user.doctor_availabilities.where(for_date: d).where("start_time BETWEEN ?  AND ?", start_date, end_date)
      if availabilities.present?
        next
      else
        start_date = d.to_datetime + availability_params[:start_time].to_datetime.hour.hour + availability_params[:start_time].to_datetime.minute.minutes
        end_date =   d.to_datetime + availability_params[:end_time].to_datetime.hour.hour + availability_params[:end_time].to_datetime.minute.minutes
        new_availability = user.doctor_availabilities.build(for_date: d)
        new_availability.start_time = start_date
        new_availability.end_time = end_date
        new_availability.duration =  availability_params[:duration]
        if new_availability.save
          while start_date < end_date
            new_availability.time_slots.create!(start_time: start_date, end_time: start_date + 30.minutes, user_id: availability_params[:user_id], status: "available")
            start_date += 30.minutes
          end
          availability_present = true
        else
          render json: {status:400, message: new_availability.time_slots.errors.full_message}
        end 
      end
    end
    if availability_present
      render json: {status: 200, data: user.doctor_availabilities, message: "Availability created"}
    else
      render json: {status: 400, data: " ", message: "Availability already created"}
    end
  end 

  def show
    if current_user.has_role?(:doctor)
      doctor = User.find_by(id: params[:user_id])
      render json: {status:404, data: " ", message: "user not found"} and return if doctor.nil?
      available_dates = []
      availabilities = doctor.doctor_availabilities.where('start_time  > ?', DateTime.now)
      render json: {status: 200, data: [], message: "no dates available"} and return if availabilities.size == 0
      sorted_availabilities = availabilities.sort_by { |hash| hash[:start_time] }
      sorted_availabilities.each do |i|
        available_dates << i.for_date
      end
      slots = []
      first_available_date = sorted_availabilities.first.for_date
      availabilities_for_first_date = DoctorAvailability.where(for_date: first_available_date, user_id: doctor.id)
      availabilities_for_first_date.each do |i|
        slots << i.time_slots.where('start_time > ?', DateTime.now.utc)
      end
      render json: {status:200, data: available_dates.uniq, time_slot: slots.flatten.sort_by {|hash| hash[:start_time]}, message: "Dates of doctor availability"}
    elsif current_user.has_role?(:patient)
      doctor = User.find_by(id: params[:user_id])
      render json: {status:404, data: " ", message: "user not found"} and return if doctor.nil?
      available_dates = []
      availabilities = doctor.doctor_availabilities.where('start_time  > ?', DateTime.now)
      render json: {status: 200, data: [], message: "no dates available"} and return if availabilities.size == 0
      availabilities.each do |i|
        
        # binding.pry
        
        available_slots = i.time_slots.where(status: "available") 
        if available_slots.size > 0
        available_dates << i.for_date
        else
          next
        end 
      end
      render json: {status:200, data: available_dates.sort, message: "Dates of doctor availability"}
    else 
    end 
  end 

  def available_slots
    # current_user = User.find_by(token: request.headers["HTTP_AUTH_TOKEN"])
    if current_user.has_role?(:doctor)   
      availabilities =  current_user.doctor_availabilities.where(for_date: params[:for_date])      
      render json: {status:404, data: " ", message: "Availability for this date is not found"} and return unless availabilities.present?
      available_slots = []
      availabilities.each do |i|
        available_slots << i.time_slots.where('start_time > ?',  DateTime.now.utc)
      end
      render json: {status: 200, data: available_slots.flatten.sort_by {|hash| hash[:start_time]}, message: "These are the time slots"}
    elsif current_user.has_role?(:patient)
      doctor = User.find_by(id: params[:doctor_id])
      availabilities =  doctor.doctor_availabilities.where(for_date: params[:for_date])
      render json: {status:404, data: " ", message: "Availability for this date is not found"} and return unless availabilities.present?
      available_slots = []
      availabilities.each do |i|
        available_slots << i.time_slots.where(status: "available").where("start_time > ?", DateTime.now.utc)
      end 
      render json: {status: 200, data: available_slots.flatten.sort_by {|hash| hash[:start_time]}, message: "there are the time slots"}
    else 
      render json: {status: 400, data: " ", message: "No role found"}
    end 
  end 

  private
  def availability_params
    params.require(:availability).permit(:user_id, :start_time, :end_time, :for_date, :duration)
  end 
end
      






# _by {|hash| hash[:date] }


      # end 

      # if availabilities.present?

        # start_time = availability.time_slots.first.start_time
        # end_time  =  availability.time_slots.last.end_time
        # new_start_time =  availability_params[:start_time]
        # new_end_time = availability_params[:end_time]
        # new_start_time = new_start_time.to_datetime
        # new_end_time = new_end_time.to_datetime

        # if start_time.strftime("%I:%M") > new_start_time.strftime("%I:%M")
        #   if end_time.strftime("%I:%M") > new_end_time.strftime("%I:%M") 
        #     while new_start_time.strftime("%I:%M") < start_time.strftime("%I:%M")
        #       availability.time_slots.create!(start_time: new_start_time, end_time: new_start_time + 30.minutes, user_id: availability_params[:user_id])
        #       new_start_time += 30.minutes
        #     end
        #   elsif end_time.strftime("%I:%M") < new_end_time.strftime("%I:%M") 
        #     while new_start_time.strftime("%I:%M") < new_end_time.strftime("%I:%M")
        #       availability.time_slots.create!(start_time: new_start_time, end_time: new_start_time + 30.minutes, user_id: availability_params[:user_id])
        #       new_start_time += 30.minutes
        #     end
        #   end 

        # elsif start_time.strftime("%I:%M") < new_start_time.strftime("%I:%M")
        #   if end_time.strftime("%I:%M") > new_end_time.strftime("%I:%M") 
        #     render json: {status:200, message: "Availability already created "}
        #   elsif end_time.strftime("%I:%M") < new_end_time.strftime("%I:%M") 
        #     while end_time.strftime("%I:%M") < new_end_time.strftime("%I:%M")
        #       availability.time_slots.create!(start_time: end_time, end_time: end_time + 30.minutes, user_id: availability_params[:user_id])
        #       end_time += 30.minutes
        #     end
        #   end 
        # else   
          # render json: {message: "Aailability already created"} and return
        # end
      # else
        
      #   start_date = d.to_datetime + availability_params[:start_time].to_datetime.hour.hour
      #   end_date =   d.to_datetime + availability_params[:end_time].to_datetime.hour.hour

      #   new_availability = user.doctor_availabilities.build(for_date: d)
      #   new_availability.start_time = start_date
      #   new_availability.end_time = end_date

      #   if new_availability.save
      #   # if user.doctor_availabilities
      #     # start_time = Time.parse(availability_params[:start_time])
      #     # end_time = Time.parse(availability_params[:end_time])
      #     while start_date < end_date
      #       new_availability.time_slots.create!(start_time: start_date, end_time: start_date + 30.minutes, user_id: availability_params[:user_id])
      #       start_date += 30.minutes
      #     end
      #   else
      #     render json: {status:400, message: new_availability.time_slots.errors.full_message}
      #   end 
      # end
  #   end
  #   render json: {data: user.doctor_availabilities, message: "Availability created"} 
  # end 





# def create
#   user = User.find_by(id: params[:user_id])
#   if user.present? && user.has_role?(:doctor)
#     if user.doctor_availability
#       user.doctor_availability.update(availability_params)
#       render json: {status: 200, data: user.doctor_availability, message: "Appointment cretaed successfully"}
#     else 
#       user.build_doctor_availability(availability_params)
#       if user.save
#         render json: {status: 200, data: user.doctor_availability, message: "Appointment cretaed successfully"}
#       else 
#         render json: {status: 400, data: "", message: user.errors.full_messages}
#       end 
#     end 
#   else 
#     render json:{status: 400, data: "", message: "User not found" }
#   end 
# end 


# if availability.timeslots.where(start_time: availability_params[:start_time]) 
#   if availability.timeslots.where(end_time: availability_params[:end_time])
#   else 

#   end 



# while start_time > end_time
              #   # end_time = start_time +30.minutes
              #   new_availability.time_slots.create!(start_time: start_time, end_time: start_time + 30.minutes, user_id:availability_params[:user_id])
              #   start_time += 30.minutes
              # end

              # unless end_time == fixed_end_time
              #   new_availability.time_slots.create!(start_time: start_time, end_time: start_time + 30.minutes, user_id:availability_params[:user_id])
              #   start_time = start_time + 30.minutes
              #   end_time = start_time
              # end 

              # while start_time.to_time < fixed_end_time.to_time
              #   new_availability.time_slots.create!(start_time: start_time, end_time: start_time + 30.minutes, user_id: availability_params[:user_id])
              #   start_time += 30.minutes
              # end





          #     start_time = user.doctor_availabilities.first.start_time
          # end_time   = user.doctor_availabilities.last.end_time

          # new_start_time =  availability_params[:start_time]
          # new_end_time = availability_params[:end_time]

          # if start_time == new_start_time && end_time == new_end_time
          #   return render json: {status: 200, message: "Availability already created"}
          # end 






          # ("start_time = ? or end_time = ?", start_date, end_date)



          # 2024-04-19T13:00:00.000Z












          # def create
          #   user = User.find_by(id: availability_params[:user_id])
          #   render json: {status:404, message: "user not found"} and return if user.nil?
        
          #   render json: {status:404, message: "invalid role"} and return unless user.has_role?(:doctor)
          
         
          #   for_date = availability_params[:for_date]
          #   dates = for_date.split(",")
          #   date_range = dates[0].to_date..dates[1].to_date
          #   date_range.each do |d|
              
          #     # binding.pry
              
          #     start_date = d.to_datetime + availability_params[:start_time].to_datetime.hour.hour
          #     end_date =   d.to_datetime + availability_params[:end_time].to_datetime.hour.hour
             
          #     availabilities = user.doctor_availabilities.where(for_date: d).where("start_time BETWEEN ?  AND ?", start_date, end_date)
        
          #     if availabilities.present?
        
                
          #       # binding.pry
                
          #       render json: {message: "Availability already created"} and return
                
          #       # existing_availability = user.doctor_availabilities
          #       # # render json: {message: "Availability already created"} and return
          #       # next if existing_availability.present?
        
          #       # next
                
        
          #       start_date = d.to_datetime + availability_params[:start_time].to_datetime.hour.hour
          #       end_date  =  d.to_datetime + availability_params[:end_time].to_datetime.hour.hour
        
          #       new_availability = user.doctor_availabilities.build(for_date: d)
          #       new_availability.start_time = start_date
          #       new_availability.end_time = end_date
                
          #       render json: {message: new_availability.errors.full_messages} and return unless new_availability.save 
          #     else
                
          #       start_date = d.to_datetime + availability_params[:start_time].to_datetime.hour.hour
          #       end_date =   d.to_datetime + availability_params[:end_time].to_datetime.hour.hour
        
          #       new_availability = user.doctor_availabilities.build(for_date: d)
          #       new_availability.start_time = start_date
          #       new_availability.end_time = end_date
          #       new_availability.duration =  availability_params[:duration]
                
          #       if new_availability.save
          #         while start_date < end_date
          #           new_availability.time_slots.create!(start_time: start_date, end_time: start_date + 30.minutes, user_id: availability_params[:user_id])
          #           start_date += 30.minutes
          #         end
        
          #       else
          #         render json: {status:400, message: new_availability.time_slots.errors.full_message}
          #       end 
          #     end
          #   end
          #   render json: {data: user.doctor_availabilities, message: "Availability created"} 
          # end 