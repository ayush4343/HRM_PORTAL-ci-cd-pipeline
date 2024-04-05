module Api::V1
  module Authorizations
    class RegisterController < ApplicationController
      before_action :authorize_request
      # before_action :check_role, only: :create

      def create  
          return render json: { message: "You are not authorized to create Users" }, status: :unprocessable_entity if unauthorized_user?

          email_check = Organization.find_by(email: params.dig("user", "email"))
          return render json: { message: "Email cannot be same as organization mail" }, status: :unprocessable_entity if email_check.present?

          return render json: { message: "Invalid role" }, status: :unprocessable_entity unless valid_role?

          shift_start_utc = to_utc_time(params.dig(:user, :shift_start))
          shift_end_utc = to_utc_time(params.dig(:user, :shift_end))
          # shift_buffer_time_utc = to_utc_time(params.dig(:user, :buffer_time))
          user_params = user_params_with_shift(params[:user], shift_start_utc, shift_end_utc)
          @user = @current_user.class.name.eql?('Organization') ? @current_user.users.new(user_params.as_json) : @current_user.organization.users.new(user_params.as_json)
          
          password_validation = PasswordValidation.new(@user.password)
          return render json: { message: 'Password is invalid' }, status: :unprocessable_entity unless password_validation.valid?
          
          if @user.save
            UserJob.set(wait_until: 10.seconds.from_now).perform_later(@user)
            render json: { user: UserSerializer.new(@user), message: "User created successfully" }, status: :created
          else
            render json: { error: format_activerecord_errors(@user.errors.full_messages) }, status: :unprocessable_entity
          end
        end

      private
       def unauthorized_user?
          @current_user.class.name.eql?('User') && !@current_user.role.permissions.pluck(:name).include?("create_users")
        end

        def valid_role?
          user_login&.roles&.ids.include?(params.dig(:user, :role_id).to_i)
        end

        def to_utc_time(timestamp)
          DateTime.parse(timestamp).strftime("%Y-%m-%dT%H:%M:%S.000").to_time.utc
        end


        def user_params_with_shift(user_params, shift_start, shift_end)
          user_params.merge(shift_start: shift_start, shift_end: shift_end)
        end

      # def user_params
      #   params.require(:user).permit(:email, :password, :first_name, :middle_name, :last_name, :phone_number, :gender, :role_id, :buffer_time, :shift_mode)
      # end
      def format_activerecord_errors(errors)
        result = []
        errors.each do |error|
          result << error
        end
        result
     end
     def user_login
        @current_user.class.name.eql?('Organization') ? @current_user : @current_user.organization
      end
    end
  end
end
