# app/services/auth_service.rb
class AuthService
  include Wisper::Publisher

  def login(user_params) 
     unless find_user_or_organization(user_params)
        broadcast(:record_found_not)
        return
      end
      if authenticate_user(user_params)
        update_device_info(user_params)
        generate_token
        user = create_response
        broadcast(:successful_login, user)
      else
        broadcast(:failed_login)
      end
  end

  private
  def find_user_or_organization(user_params)
     email = user_params["email"].downcase
    if User.find_by_email(email).present?
      @user = User.find_by_email(email)
    else 
      @organization = Organization.where('LOWER(email) = ?', email).first
    end
  end

  def authenticate_user(user_params)
    if @user.present?
      @user.present? && @user.authenticate(user_params["password"])
    else
      @organization.authenticate(user_params["password"])
    end
  end

  def update_device_info(user_params)
    if @user.present?
      @user.update_columns(device_type: user_params["device_type"], device_token: user_params["device_token"])    
    else
      @organization.update_columns(device_type: user_params["device_type"], device_token: user_params["device_token"])
    end
  end

  def generate_token
    if @user.present?
      @token = JsonWebToken.encode(user_id: @user.id)
      @time = Time.now + 24.hours.to_i
    else
      @token = JsonWebToken.encode(organization_id: @organization.id)
      @time = Time.now + 24.hours.to_i
    end

  end

  def create_response
    if @user.present? 
      {
        token: @token,
        message: "Logged in successfully",
        data: @user,
        face_url: @user.face_enroll.attached? ? Rails.application.routes.url_helpers.rails_blob_url(@user.face_enroll) : nil,
        exp: @time.strftime("%m-%d-%Y %H:%M")
      }
    elsif @organization.present?
      {
        token: @token,
        message: "Logged in successfully",
        data: @organization,
        exp: @time.strftime("%m-%d-%Y %H:%M")
      }
    else
      error_model(400, "user not found")
    end
  end

  def error_model(status, message)
    { status: status, message: message}
  end
end
