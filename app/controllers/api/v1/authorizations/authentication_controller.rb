module Api::V1
  module Authorizations
    class AuthenticationController < ApplicationController
      before_action :authorize_request
      skip_before_action :authorize_request, only: :login

      def login
        response = AuthService.new()
          response.on(:record_found_not) do |user|
            return render json: {
              error: 'Record not found'
            }, status: :unprocessable_entity
          end
          response.on(:failed_login) do |user|
           return  render json: {
              error: 'enter correct password'
            }, status: :unauthorized
          end
          response.on(:successful_login) do |user, token|
            render json:  {data: user}
          end
        response = response.login(login_params)
      end

      def face_enroll
        if @current_user.class.name.eql?('Organization') || @current_user.class.name.eql?('User') && @current_user.role.permissions.pluck(:name).include?("update_users") && @current_user&.organization&.users&.ids&.include?(params[:id].to_i)
          @user = User.find_by(id: params[:id]) 
          @user.face_enroll.attach(params[:face_enroll].as_json)
          render json: { user: UserSerializer.new(@user), message: "User face enrolled successfully" }, status: :ok
        else
          render json: {message: "You are not authorised to enroll face "}, status: :unprocessable_entity
        end
      end

      private
      def login_params
        params.require(:data).permit(:email, :password, :device_type, :device_token )
      end
      def format_activerecord_errors(errors)
        result = []
        errors.each do |error|
          result << error
        end
      result
      end
    end
  end
end
