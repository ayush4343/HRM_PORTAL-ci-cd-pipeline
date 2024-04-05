module Api
  module V1
    module Regularizations
      class RegularizationsController < ApplicationController
        before_action :authorize_request
        before_action :check_user, only: :create
        before_action :check_attendance, only: :create
        before_action :authorized_to_show_regularizations_log?, only: [:action_by_user_wise_regularizations, :action_by_user_wise_monthly_regularizations]

        include Api::V1::RegularizationsHelper
        def create
          regularizations = @current_user.regularizations.where(attendance_id: params[:data][:attendance_id])
          unless regularizations.present? && regularizations.pluck(:status).include?("pending")
            reg_punch_in_times = to_utc_time_punch_in(params[:data][:reg_punch_in_times])
            reg_punch_out_times = to_utc_time_punch_out(params[:data][:reg_punch_out_times])
            regularization_params = regularization_params(params[:data], reg_punch_in_times, reg_punch_out_times, "pending", Date.current)

            @regularization = @current_user.regularizations.new(regularization_params.as_json)

            @regularization.requested_by = @current_user.first_name
            @regularization.action_by = @user.first_name
            if @regularization.save
              AttendanceAdjustmentJob.set(wait_until: 10.seconds.from_now).perform_later(@regularization.user, @regularization, @current_user)
              render json: { data: RegularizationSerializer.new(@regularization), message: "Regularization requests were successfully submitted" }, status: :created
            else
              render json: { error: @regularization.errors.full_messages }, status: :unprocessable_entity
            end          
          else 
            render json: {message: "You have already pending the require can't create"}, status: :unprocessable_entity
          end  
        end

        def index
          regularization = {}
          if @current_user.instance_of?(Organization)
            @current_user.users.each do |user|
              user_regularizations = render_regularizations_log_for_current_user(user)
              user_regularizations.each do |month, data|
                regularization[month] ||= []
                regularization[month] << data
              end
            end
            render json: regularization, status: :ok
          else
            render json: {message: "You are not authorized to show regularization request"}, status: :unprocessable_entity
          end
        end

        def current_user_regularizations
          if @current_user.type.eql? 'User'
            regularization = render_regularizations_log_for_current_user(@current_user)
            render json: regularization
          else
            render json: {message: "You are not authorized to show regularization request"}, status: :unprocessable_entity
          end
        end

        def action_by_user_wise_regularizations
         regularization = render_regularizations_log_for_assignee(@current_user)
         render json: regularization
        end

        def current_user_monthly_regularizations
          month =  params['month'].to_i
          year  = params['year'].to_i
          user = @current_user
          if @current_user.type.eql? 'User'
            data = render_month_regularization_log(user, month, year)
            render json: data   
          else
              render json: {message: "You are not authorized to show regularization request"}, status: :unprocessable_entity
          end
        end

        def action_by_user_wise_monthly_regularizations
          month =  params['month'].to_i
          year  = params['year'].to_i
          user = @current_user
          regularization = render_month_regularization_log_for_assignee(user, month, year)
          render json: regularization
        end
        def organization_wise_user_monthly_regularization
          @month =  params['month'].to_i
          @year  = params['year'].to_i
          regularization = {}
          if @current_user.instance_of?(Organization)
            @current_user.users.each do |user|
              user_regularizations = render_month_regularization_log(user, @month, @year)
              user_regularizations.each do |month, data|
                regularization[month] ||= []
                regularization[month] << data
              end
            end
            render json: regularization, status: :ok
          else
            render json: {message: "You are not authorized to show regularization request"}, status: :unprocessable_entity
          end
        end

        def update
          @regularization = Regularization.find_by(id: params[:id])
          return render_error("Regularization request not found") if @regularization.nil?
          case @current_user.type
          when 'Organization'
            update_organization_regularization(params[:data][:status])
          when 'User'
            update_user_regularization(params[:data][:status])
          else
            render_error("Unauthorized access")
          end
        end

        private 

        def update_organization_regularization(status)
          if status == "approved" || status == "rejected"
            update_regularization(@regularization)
          else
            render_error("Unauthorized access")
          end
        end

        def update_user_regularization(status)
          if action_by_user? ? params[:data][:status] == "approved" || params[:data][:status] == "rejected": false
            update_regularization(@regularization) unless status == "cancel"
          elsif status == "cancel" && @regularization.user == @current_user
            update_regularization(@regularization)
          else
            render_error("Unauthorized access")
          end
        end

        def render_error(message)
          render json: { error: message }, status: :unprocessable_entity
        end

        def update_regularization(regularization)
          if regularization.update_columns(status: params[:data][:status], comment: params[:data][:comment])
            SendApprovalEmailJob.set(wait_until: 10.seconds.from_now).perform_later(regularization.user, regularization, @current_user)
            render json: { message: "Regularization request updated successfully!" }
          else
            render json: { error: regularization.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def action_by_user?
          if @current_user.type.eql?('User') && @current_user&.role&.permissions&.pluck(:name).include?("regularizations_request")
            return true
          else
            return false
          end
        end

        def authorized_to_show_regularizations_log?
          if @current_user.type.eql? 'User'
           if  @current_user&.role&.permissions&.pluck(:name).include?("regularizations_request")
            return true
           else
              render json: { message: "You are not authorized to show regularization log" }, status: :unprocessable_entity
           end
          else
            render json: { message: "You are not authorized to show regularization log" }, status: :unprocessable_entity
          end
        end

        def check_user
          params[:data][:user_ids].each do |user|
             @user = User.find_by(id: user)
             unless @user.present? && @current_user&.organization&.users&.ids.include?(@user.id)
              render json: {message: "user not found or not authorized"}, status: :unprocessable_entity
             end
          end    
        end

        def check_attendance
           @attendance = Attendance.find_by(id: params[:data][:attendance_id])
           unless @attendance.present? && @current_user&.attendances&.ids.include?(params[:data][:attendance_id])
            render json: {message: "attendance not found or not authorized"}, status: :unprocessable_entity
           end
        end

        def regularization_params(regularization_params, reg_punch_in_times, reg_punch_out_times, status, date)
          regularization_params.merge(reg_punch_in_times: reg_punch_in_times, reg_punch_out_times: reg_punch_out_times, status: status, date: date)
        end   
      end
    end
  end
end
