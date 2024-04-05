module Api::V1
  module Authorizations
    class PasswordsController < ApplicationController
      before_action :authorize_request, only: [:change_password, :reset_password]

      def change_password
        user = User.find(@current_user.id)
        if params[:old_password].present? || params[:new_password].present?
          unless user.authenticate(params[:old_password])
            return render json: {
                message: 'Please enter a correct old password.'}, status: :unprocessable_entity
          end
          password_validation = PasswordValidation.new(params[:new_password])
          is_valid = password_validation.valid?
          error_message = password_validation.errors.full_messages.first
          unless is_valid
            return render json: {
              message: 'Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character'}, status: :unprocessable_entity
          end
          unless params[:confirm_password].eql?(params[:new_password])
            return render json: {
              message: 'New password and confirm password should be same.'}, status: :unprocessable_entity
          end
        end
        if user.present? && params[:old_password].present?
          user.update(password: params[:new_password])
          return render json: {data: UserSerializer.new(user),message: "Password Updated Successfully"}
        else
          render json: {message: 'Record Not Found.'}, status: :unprocessable_entity
        end
      end

      def forgot_password
        @email = params[:email].downcase
        @user = User.find_by(email: @email)

        if @user.present?
          if UserOtp.where(user_id: @user.id, created_at: Date.today.beginning_of_day..Time.now).count >= 10
            render json: { message: "otp_limit_exists" }, status: :unprocessable_entity
            return
          end

          # Static OTP for testing
          random_number = 123456
          @user.user_otps.create(verification_code: random_number)

          # Dynamic OTP for Twilio
          @random_number = 4.times.map { rand(1..9) }.join
          otp = UserOtpJob.set(wait_until: 10.seconds.from_now).perform_later(@user, @random_number, request.base_url)
          if otp.successfully_enqueued?
            user_otp = @user.user_otps.create(verification_code: @random_number)
            render json: { message: "OTP sent successfully", user: UserOtpSerializer.new(user_otp) }, status: :ok
          else
            render json: { message: "Unable to send sms for verification. #{otp.exception}", status: :unprocessable_entity }
          end
        else
          render json: { message: "Email not registered" }, status: :unprocessable_entity
        end
      end

      def reset_password_verify_email
        @email = params[:email].downcase
        @user = User.find_by(email: @email)
        if @user.present?
          user_otps = UserOtp.where(user_id: @user.id, created_at: Date.today.beginning_of_day..DateTime.now)
          unless user_otps.present?
              render json: {message: "verification_code_incorrect"}, status: :unprocessable_entity
            return
          end
          otp_include = user_otps&.map{|x| x.verification_code}.include?(params["otp"].to_i)
          if otp_include
            user_otp = UserOtp.find_by(user_id: @user.id, verification_code: params["otp"])
            if Time.now - user_otp.created_at > 5.minute
              render json: {message: "otp_expire"}, status: :unprocessable_entity
              return
            end
            if user_otp.verification_code == params["otp"].to_i
              if @user.update(mobile_verified_for_reset_password: true)
                @user.user_otps.destroy_all
                success_response('email_verified_success')
              else
                render json: {error: format_activerecord_errors(@user.errors.full_messages)},
                status: :unprocessable_entity
                  return
              end
            else
              render json: {message: "verification_code_incorrect"}, status: :unprocessable_entity
              return
            end
          else
            render json: {message: "verification_code_incorrect"}, status: :unprocessable_entity
            return
          end
        else
          render json: {message: "user_not_found_with_given_email"}, status: :unprocessable_entity
        end
      end
      def reset_password
        @user = @current_user
        password_validation = PasswordValidation.new(params[:new_password])
          is_valid = password_validation.valid?
          error_message = password_validation.errors.full_messages.first
          unless is_valid
            return render json: {
              error: 
                'Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character'
            }, status: :unprocessable_entity
          else
            # Update user with new password
            unless params[:confirm_password].eql?(params[:new_password])
               return render json: {
                error: 
                  'New password and confirm password should be same.'
              }, status: :unprocessable_entity
            end

            if @user.authenticate(params[:new_password])
              return render json: {
                error:'New Password should not be same as old password.'
              }, status: :unprocessable_entity
            end
            if @user.update(password: params[:new_password], mobile_verified_for_reset_password: false, password_updated: true)
              render json: {message: 'New Password set Successfully.' }
            else
              render json: {error: format_activerecord_errors(@user.errors.full_messages)},
              status: :unprocessable_entity
            end
          end
      end

      private
      def success_response(message)
        response = {}
        user = @user
        @token = JsonWebToken.encode(user_id: user&.id)
        @time = Time.now + 24.hours.to_i
        render json: { token: @token, time: @time, message: message }
      end
    end
  end
end
