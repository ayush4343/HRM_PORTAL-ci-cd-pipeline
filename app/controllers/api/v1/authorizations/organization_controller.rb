module Api::V1
  module Authorizations
    class OrganizationController < ApplicationController
        before_action :authorize_request, only: [:organization_change_password, :organization_reset_password, :show_all_employee, :create_geofencing]

      def create
        ActiveRecord::Base.transaction do 
          @organization = Organization.new(organization_params)
          if User.find_by(email: @organization.email).present?
            return render json: { message: "Invalid Email! You cannot create organization using these email."}
          end
          password_validation = PasswordValidation.new(params[:organization][:password])
          is_valid = password_validation.valid?
          error_message = password_validation.errors.full_messages.first
          unless is_valid
            return render json: {
              message: 'Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character'}, status: :unprocessable_entity
          end
          if @organization.save
            OrganizationWelocmeEmailJob.set(wait_until: 10.seconds.from_now).perform_later(@organization)
            render json: { organization: OrganizationSerializer.new(@organization), message: "organization created succesfully" },status: :created
          else
           render json: {error: format_activerecord_errors(@organization.errors.full_messages)},
            status: :unprocessable_entity
          end
        end
      end

      def organization_change_password
        organization = Organization.find(@current_user.id)
        if params[:old_password].present? || params[:new_password].present?
          unless organization.authenticate(params[:old_password])
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
        if organization.present? && params[:old_password].present?
          organization.update(password: params[:new_password])
          return render json: {data: OrganizationSerializer.new(organization),message: "Password Updated Successfully"}
        else
          render json: {message: 'Record Not Found.'}, status: :unprocessable_entity
        end
      end

      def organization_forgot_password
        @email = params[:email]&.downcase
        @organization = Organization.find_by(email: @email)   
        if @organization.present?
          if OrganizationOtp.where(organization_id: @organization.id, created_at: Date.today.beginning_of_day..Time.now).count >= 10
            render json: { message: 'otp_limit_exists.' }, status: :unprocessable_entity
            return
          end   
          # Generate OTP
          @random_number = 4.times.map { rand(1..9) }.join
          otp = UserOtpJob.set(wait_until: 10.seconds.from_now).perform_later(@organization, @random_number, request.base_url) 
          if otp.successfully_enqueued?
            @organization_otp = @organization.organization_otps.create(verification_code: @random_number)
            render json: { message: "otp send successfully", organization: OrganizationOtpSerializer.new(@organization_otp) }, status: :ok
          else
            render json: { message: "Unable to send sms for verification. #{otp.exception}", status: :unprocessable_entity }
          end
        else
          render json: { message: 'email_not_register' }, status: :unprocessable_entity
        end
      end


      def organization_reset_password_verify_email
        @email = params[:email].downcase
        @organization = Organization.find_by(email: @email)
        if @organization.present?
          organization_otp = OrganizationOtp.where(organization_id: @organization.id, created_at: Date.today.beginning_of_day..DateTime.now)
          unless organization_otp.present?
            render json: { message: 'verification_code_incorrect'}, status: :unprocessable_entity
            return
          end
          otp_include = organization_otp&.map{|x| x.verification_code}.include?(params["otp"].to_i)
          if otp_include
            organization_otp = OrganizationOtp.find_by(organization_id: @organization.id, verification_code: params["otp"])
            if Time.now - organization_otp.created_at > 5.minute
              render json: {message: 'otp_expire'}, status: :unprocessable_entity
              return
            end
            if organization_otp.verification_code == params["otp"].to_i
              if @organization.update(email_verified_for_reset_password: true)
                 @organization.organization_otps.destroy_all
                success_response('email_verified_success')
              else
                render json: {error: format_activerecord_errors(@organization.errors.full_messages)},
                status: :unprocessable_entity
                return
              end
            else
              render json: {message:  'verification_code_incorrect'}, status: :unprocessable_entity
              return
            end
          else
            render json: {message:  'verification_code_incorrect'}, status: :unprocessable_entity

            return
          end
        else
          render json: {message:  'user_not_found_with_given_email'}, status: :unprocessable_entity

        end
      end

      def organization_reset_password
        @organization = @current_user
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

            if @organization.authenticate(params[:new_password])
              return render json: {
                error:'New Password should not be same as old password.'
              }, status: :unprocessable_entity
            end
            if @organization.update(password: params[:new_password], email_verified_for_reset_password: false, password_updated: true)
              render json: {message: 'New Password set Successfully.' },status: :ok

            else
              render json: {error: format_activerecord_errors(@organization.errors.full_messages)},
             status: :unprocessable_entity
            end
          end
      end

      def show_all_employee
        case params["permission_type"] || @current_user.is_a?(Organization) || @current_user.is_a?(User)
        when "show_users"
          if @current_user&.respond_to?(:role) && @current_user.role&.permissions&.pluck(:name).include?("show_users")
            if params[:query].present?
              search_data = @current_user.organization.users.where("first_name ILIKE ? OR first_name ILIKE ?", "%#{params[:query].downcase}%", "#{params[:query].split(' ').first.downcase}%")
              render json: search_data, each_serializer: UserSerializer, status: :ok
            else
              users = @current_user.organization.users
              render json: users, each_serializer: UserSerializer, status: :ok
            end
          else
            render json: { message: "You are not authorized" }, status: :unprocessable_entity

          end
        when "regularizations_request"
          users = []
          if @current_user&.respond_to?(:role) && @current_user.is_a?(User)
            permission = Permission.find_by(name: 'regularizations_request')
              permission&.roles.each do |role|
                 users << role&.users&.where(organization_id: @current_user.organization.id)
              end
            if params[:query].present?
              search_data = users&.where("first_name ILIKE ? OR first_name ILIKE ?", "%#{params[:query].downcase}%", "#{params[:query].split(' ').first.downcase}%")
              render json: search_data, each_serializer: UserSerializer, status: :ok
            else
              render json: users.flatten, each_serializer: UserSerializer, status: :ok
            end
          else
            render json: { message: "You are not authorized" }, status: :unprocessable_entity

          end
        when @current_user.is_a?(Organization)
          
          if params[:query].present?
            search_data = @current_user.users.where("first_name ILIKE ? OR first_name ILIKE ?", "%#{params[:query].downcase}%", "#{params[:query].split(' ').first.downcase}%")
            render json: search_data, each_serializer: UserSerializer, status: :ok
          else
            render json: @current_user.users, each_serializer: UserSerializer, status: :ok
          end
        else
          render json: { message: "You are not authorized" }, status: :unprocessable_entity

        end
      end


      def create_geofencing
        if @current_user.class.name.eql?('Organization')
           @goefencing = @current_user.geofencings.new(params["data"].as_json)
           if @goefencing.save
            render json: {data: @goefencing}, status: :created
           else
            render json: {error: format_activerecord_errors(@goefencing.errors.full_messages)},
             status: :unprocessable_entity
           end
        else
          render json: {message: "You are not authorized"}, status: :unprocessable_entity
        end
      end


      private
      def success_response(message)
        response = {}
        organization = @organization
        @token = JsonWebToken.encode(organization_id: organization&.id)
        @time = Time.now + 24.hours.to_i
        render json: { token: @token, time: @time, message: message }
      end

      def organization_params
        params.require(:organization).permit(:email, :password, :company_name, :website, :contact, :owner_name, :address)
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
