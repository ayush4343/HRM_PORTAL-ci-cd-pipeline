class ApplicationController < ActionController::Base
  include JsonWebToken
  include Response

  before_action :authorize_request unless :active_admin_controller?
  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from StandardError, with: :handle_standard_error

  def not_found
    render json: { error: 'not_found' }
  end

  def authorize_request
    header = request.headers['token']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      if @decoded["organization_id"].present?
         @current_user = Organization.find(@decoded[:organization_id])
      elsif @decoded[:user_id].present?
         @current_user = User.find(@decoded[:user_id])
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unauthorized
    rescue JWT::ExpiredSignature => e
      render json: { error: 'Token has Expired'},
          status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: e.message }, status: :unauthorized
    
    end

  end

  def organization_authorize_request
    header = request.headers['token']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = Organization.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: e.message }, status: :unauthorized
    end
  end
  
  private
  def format_activerecord_errors(errors)
      result = []
      errors.each do |error|
        result << error
      end
    result
  end

  def record_not_found
    return render json: {error: 'Record not found'}, status: :not_found
  end

  def handle_standard_error(error)
    return render json: {error: "An unexpected error occurred: #{error.message}"}, status: :internal_server_error
  end

  def active_admin_controller?
    self.is_a?(ActiveAdmin::BaseController)
  end

end
