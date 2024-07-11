class UsersController < ApplicationController
  before_action :authenticate_user, only: [:log_out, :show_doctor, :doctor_details, :show, :update]

  def index
    user = User.all
    render json: user
  end 

  def show
    user = User.find(params[:id])
    render json: {status: 400, data: " ", message: "Invalid credentials"} and return unless current_user.id == user.id
    begin
      if user.present?
        if user.has_role? :patient
          data = {}
          data[:user_data] = user
          data[:emergency_data] = user.emergency_contact_detail
          data[:address_data] = user.user_address
          render json: {status: 200, data: data, message: "This is the data of #{user.first_name}"}
        elsif user.has_role? :doctor
          data = {}
          data[:user] = user
          data[:doctor_information] = user.doctor_information
          data[:hospital_data] = user.hospital
          data[:pic] = user.profile_pic.url
          render json: {status: 200, data: data}
        else 
          render json: {status: 400, success: false, message: "Invalid Role"}
        end
      else
        render json: {status: 400, success: false, message: "user not found"}
      end
    rescue => e
      render json: {status: 400, success: false, message: e}
    end 
  end 

  def update
    user = User.find_by(id:params[:id])
    render json: {status: 400, data: " ", message: "Invalid credentials"} and return unless current_user.id == user.id
    render json: {status: 400, data: "", message: 'User not found'} and return if user.nil?

    if user.has_role? :patient
      update_patient_details(user)
    elsif user.has_role? :doctor
      update_doctor_details(user)
    else 
      render json: {status: 400, data: "", message: "Invalid User"}
    end
  end 

  def update_patient_details(user)
    if params[:user].present?
      render json: {status: 400, data: "", message: user.errors.full_messages} and return unless user.update(user_params)
    # else 
    #   render json: {status: 400, data: "", message: "Required parameters missing"}
    end
    if params[:address].present?
      render json: { status:400, message: user.user_address.errors.full_messages} and return unless user.user_address.update(address_params)   
    end 
    if params[:emergency_contact].present?
      render json: {status:400, message: user.emergency_contact_detail.errors.full_messages} and return unless user.emergency_contact_detail.update(emergency_contact_params)
    end 
    data = {}
    data[:user_data] = user
    data[:address_data] = user.user_address
    data[:emergency_data] = user.emergency_contact_detail
    render json: {status: 200, data: data, message: "Data updated successfully"}
  end

  def update_doctor_details(user)
    if params[:user].present?
      render json: {message: user.errors.full_messages} and return unless user.update(user_params)
    end 
    if params[:doctor_info].present?
      if user.doctor_information
        user.doctor_information.update(doctor_params)
      else 
        user.build_doctor_information(doctor_params)
        render json: {status:400, message: user.doctor_information.errors.full_messages} and return unless user.doctor_information.save
      end 
    end 
    if params[:hospital_info].present?
      if user.hospital
        user.hospital.update(hospital_params)
      else 
      user.build_hospital(hospital_params)
      render json: {status:400, message: user.hospital.errors.full_messages} and return unless user.hospital.save
      end 

    end 
    # render json: {status: 200, user_data: user, doctor_info: user.doctor_information, hospital_data: user.hospital, message: "updated successfully"}

    render json: {status: 200, user_data: user, doctor_info: user.doctor_information, hospital_data: user.hospital, message: "updated successfully"}
  end 

  def sign_up
    begin   
      if params[:user].present?
        user = User.new(user_params.merge(status: "active"))
        role = params[:role]
        if role == "patient" || role == "doctor"
          if user.save 
            user_role = Role.find_by(name:role)
            user.roles << user_role
            if user.has_role? :patient
              address_data = user.build_user_address(address_params)
              emergency_data = user.build_emergency_contact_detail(emergency_contact_params)
              if address_data.save && emergency_data.save
                patient_data = {}
                patient_data[:user_data] = user
                patient_data[:address_data] = address_data
                patient_data[:emergency_data] = emergency_data
                generate_token(user)
                render json: {status: 200, data: patient_data, message: "New user registered successfully"}
              else 
                render json: {status: 400,  data: "", message: "Invalid details"}
              end
            elsif user.has_role? :doctor
              generate_token(user)
              render json: {status: 200, data: user, message: "New user registered successfully"}
            else 
              render json: {status: 400, data: "", message: "role not defined"}
            end 
          else 
            error_message = user.errors.full_messages.first
            render json: {status: 400, data: "", message: error_message}
          end 
        else 
          render json: {status: 404, data: "", message: "Role not found"}
        end 
      else 
      render json: {status: 400, data: "", message: "required parameters missing"}
      end
    rescue => e
    render json: {status: 400, data: "", message: e}
    end
  end 

  def log_in
    if params.present?
      user = User.find_by_email(params[:email])
      if user.present?
        if user.authenticate(params[:password])
          generate_token(user)
          user_token = {}
          user_token[:token] = user.token
          user_token[:user_id] = user.id
          render json: {status: 200, data: user_token, message: "successfully logged in"}
        else 
          render json: {status: 400, data: "", message: "Password is incorrect"}
        end 
      else
        render json: {status: 400, data: "", message: "Email or password is invalid"}
      end 
    else 
      render json: {status: 400, data: "", message: "Required parameters are missing"}
    end 
  end 

  def log_out
    current_user.update_attribute(:token, nil)
    render json: {status: 200, logout_data: "", message: "logged out successfully"}
  end

  def doctor_details
    render json: {status: 400, data: " ", message: " Only patient can get the details"} and return unless current_user.has_role?(:patient)
    doctor_users = User.with_role(:doctor)
    array = []
     doctor_users.each do |user|
      array << {
        user: user,
        hospital: user.hospital,
        doctor_info: user.doctor_information
      }
    end
      render json: {status: 200, data: array, message: "data of all doctors"} 
  end 

  def show_doctor
    if current_user.has_role?(:patient)
      doctor = User.find_by(id: params[:id])
      render json: {status: 400, data: " ", message: "This doctor does not exits"} and return unless doctor.has_role?(:doctor)
      doctor_data = [] 
      doctor_data << {
        user: doctor, 
        hospital: doctor.hospital,
        doctor_info: doctor.doctor_information,
        # pic: doctor.profile_pic.url
      }
      render json: {status: 200, data: doctor_data, message: "Doctor's details"}
    else 
      render json: {status: 400, data: " ", message: "You are not authorised"}
    end 
  end 

  private 
  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone_no, :email, :password, :dob, :gender, :status, :profile_pic_file_name)
  end 

  def emergency_contact_params 
    params.require(:emergency_contact).permit(:name, :phone_no, :relation)
  end 

  def address_params
    params.require(:address).permit(:line1, :line2, :city, :pincode)
  end 

  def doctor_params
    params.require(:doctor_info). permit(:language, :specialization, :about, :charges, :profile_pic_file_name)
  end 

  def hospital_params
    params.require(:hospital_info). permit(:name, :address, :city, :state, :pincode)
  end 

  def generate_token(user)
    payload = {email: user.email, phone_no: user.phone_no, first_name: user.first_name, timestamp: DateTime.now}
    secret_key = Rails.application.secrets.secret_key_base
    token = JWT.encode(payload, secret_key, 'HS256')
    user.update_attribute(:token, token)
  end  

  def validate_gender(gender)
    User.genders.include? (gender)
  end 
end 



  # def user_params
  #   params.require(:user).permit(
  #     :first_name, :last_name, :phone_no, :email, :password, :dob, :gender, 
  #     emergency_contact_details_attributes:[:id, :user_id, :name, :phone_no, :relation, :_destroy], 
  #     user_addresses_attributes:[:id, :user_id, :line1, :line2, :city, :pincode, :_destroy]
  #   )
  # end 

# address_data  = user.user_addresses.new(user_params[:user_addresses]
 # emergency_data  = user.emergency_contact_details.new(user_params[:emergency_contact_details])


# address = UserAddress.new(user_address_params)
    # emergency = EmergencyContactDetails.new(user_emergency_params)
    # if address.save && emergency.save
    #   generate_token(user)
    #   render json: { data: user, message: 'New user registered successfully' }
    # else
    #   error_messages = { address: address.errors.full_messages, emergency: emergency.errors.full_messages }
    #   render json: { status: 400, success: false, message: error_messages }
    # end



     # def sign_up
  #   user = User.new(user_params)
  #   if user.save
  #     #user.add_role(user_params[:role])
  #     #if user.has_role? :patient
  #       address = UserAddress.new(user_address_params)
  #       emergency = EmergencyContactDetails.new(user_emergency_params)
  #       if address.save && emergency.save
  #           generate_token(user)
  #           render json: { data: user, message: 'New user registered successfully' }
  #         else
  #           error_messages = { address: address.errors.full_messages, emergency: emergency.errors.full_messages }
  #           render json: { status: 400, success: false, message: error_messages }
  #         end
  #       else
  #         render json: { message: 'Data entry into address and emergency tables is not required for this role' }
  #       end
  #       error_message = user.errors.full_messages.first
  #       render json: { status: 400, success: false, message: error_message }
  #     end
  #   end



  # else
      #   error_message = user.errors.full_messages.first
      #   render json: {success: false, message: error_message}, status: 400
      # end



      
      # def log_in
      #   user = User.find_by_email(params[:email])
        
      #   # binding.pry
        
      #   if user.present?
      #     if user.authenticate(params[:password])
      #       # render json: {message: "successfully logged in", token: user.token}, status: 200
      #       if user.token.nil?
      #         generate_token(user)
      #         render json: {message: "successfully logged in", token: user.token}, status: 200
      #       else
      #         generate_token(user)
      #         # user.update(login_token)
      #         render json: {message: "successfully logged in", token: user.token}, status: 200
      #       end
      #     else 
      #       render json: {message: "Password is incorrect"}, status: 400
      #     end 
      #   else
      #     render json: {message: "Email or password is invalid"}, status: 400
      #   end 
      # end 



      # ['pattient', 'doctor'].include? role



