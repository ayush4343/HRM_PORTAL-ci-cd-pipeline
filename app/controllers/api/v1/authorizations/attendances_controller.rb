module Api::V1
  module Authorizations
    class AttendancesController < ApplicationController
      before_action :authorize_request, only: [:create_attendance, :show_all_attendance_log, :show_month_wise_attendance_log]
      include  Api::V1::AttendanceHelper
      def create_attendance
        return render json: { message: "You are not authorized to create attendance" }, status: :unprocessable_entity if !@current_user.class.name.eql?('User')
        
        user_latitude = params[:data][:latitude].to_f
        user_longitude = params[:data][:longitude].to_f
        # holidays = @current_user.organization.public_holidays
        # if holiday_today?(holidays)
        #   return render json: { error: 'Today is a holiday. Attendance cannot be created.' }, status: :unprocessable_entity
        # end

        action = action_type
        if find_organization
          if action_valid?(action)
            if fetch_geofence(user_latitude, user_longitude)
              attendance = @current_user.attendances.find_or_initialize_by(date: Date.current)
              attendance.send("#{action}_times") << Time.now.utc
              attendance.status = @status if @status.present?
              result = Geocoder.search([user_latitude, user_longitude]).first
                if result
                  attendance.address = result.address if result.address.present?
                end
              if attendance.save
                render json: { message: "Attendance #{action == 'punch_in' ? 'punched in' : 'punched out'} successfully" }, status: :created
              else
                render json: { error: 'Failed to save attendance record' }, status: :unprocessable_entity
              end 
            else
              render json: { error: 'User is not within attendance location' }, status: :unprocessable_entity
            end
          else
            render json: { error: 'Invalid action type' }, status: :unprocessable_entity
          end
        else
          render json: { error: 'Invalid user'}, status: :unprocessable_entity
        end
      end

      # code by sonu rathor
      def show_all_attendance_log
        user_type = @current_user&.type
        user_id = params['user_id']      
        if authorized_to_show_attendance_log?
          if user_type.eql?('Organization') || @current_user&.role&.permissions&.pluck(:name).include?("attendance_log")
            @user = find_user_by_type_and_id(user_type, user_id)
            if @user.present?
              render_attendance_log(@user)
            else
              render json: { message: "User not found" }, status: :unprocessable_entity
            end
          elsif user_type.eql?('User')
            if user_id == @current_user.id.to_s
              render_attendance_log_for_current_user
            else
              render json: { message: "You are not authorized to view attendance logs for this user" }, status: :unprocessable_entity
            end
          end
        else
          render json: { message: "You are not authorized to show attendance log" }, status: :unprocessable_entity
        end
      end

      def show_month_wise_attendance_log
        user_type = @current_user&.type
        user_id = params['user_id']     
        if authorized_to_show_attendance_log?
          if user_type.eql?('Organization') || @current_user&.role&.permissions&.pluck(:name).include?("attendance_log")
            @user = find_user_by_type_and_id(user_type, user_id)
            if @user.present?
              month = params['month'].to_i
              year = params['year'].to_i
              render_month_attendance_log(@user, month, year)
            else
              render json: { message: "User not found" }, status: :unprocessable_entity
            end
          elsif user_type.eql?('User')
            if user_id == @current_user.id.to_s
              month = params['month'].to_i
              year = params['year'].to_i
              render_month_attendance_log_for_current_user(month, year)
            else
              render json: { message: "You are not authorized to view attendance logs for this user" }, status: :unprocessable_entity
            end
          end
        else
          render json: { message: "You are not authorized to show attendance log" }, status: :unprocessable_entity
        end
      end

      private

      def holiday_today?(holidays)
        today = Date.current
        holidays.any? { |holiday| (holiday.start_date..holiday.end_date).cover?(today) }
      end

      def find_organization
        @organization = @current_user.organization.geofencings
      end

      def fetch_geofence(user_latitude, user_longitude)
        @organization.each do |organization|
          distance = Geocoder::Calculations.distance_between(
            [user_latitude, user_longitude],
            [organization.latitude.to_f, organization.longitude.to_f], units: :km
          )*1000

          if distance <= organization.radius
            return true
          end
        end
        return false
      end

      def authorized_to_show_attendance_log?
        if @current_user.type.eql? 'user' 
         @current_user&.role&.permissions&.pluck(:name).include?("attendance_log")
        else
         return true   
        end
      end

      def find_user_by_type_and_id(user_type, user_id)
        if user_type.eql?('User')
          User.find_by(id: user_id)
        elsif user_type.eql?('Organization')
           @current_user.users.find_by(id: user_id)
        end
      end

       def render_attendance_log(user)
         monthly_attendance_data = user.attendances.where("date >= ?", 30.days.ago.beginning_of_day)
                                                          .sort_by { |x| x.date }
                                                          .group_by { |attendance| attendance.date.strftime("%b").downcase }

        formatted_data = {}
        monthly_attendance_data.each do |month, attendances|
          formatted_data[month] = []
          attendances.each do |attendance|
            attendance_data = {
              date: attendance.date.to_date.to_s,
              attendance_info: {
                id: attendance.id,
                log: []
              }
            }

            attendance.punch_in_times.each_with_index do |punch_in_time, index|
              punch_in = punch_in_time.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
              punch_out = attendance.punch_out_times[index]&.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
              attendance_data[:attendance_info][:log] << {
                punch_in_times: punch_in,
                punch_out_times: punch_out
              }
            end

            total_time = calculate_total_time(attendance.punch_in_times, attendance.punch_out_times)
            gross_hours = hours_worked_today(attendance.punch_in_times, attendance.punch_out_times)
            regularization_data = fetch_regularization_data(attendance.regularizations)

            attendance_data[:attendance_info].merge!(
              status: attendance.status,
              address: attendance.address,
              punch_type: attendance.punch_type,
              total_time: total_time, 
              gross_hours: gross_hours,
              user_id: attendance.user_id,
              created_at: attendance.created_at,
              updated_at: attendance.updated_at,
              regularization_log: regularization_data

            )

            formatted_data[month] << attendance_data
          end
        end

        render json: formatted_data
       end

      def render_attendance_log_for_current_user
        monthly_attendance_data = @current_user.attendances.where("date >= ?", 30.days.ago.beginning_of_day)
                                                          .sort_by { |x| x.date }
                                                          .group_by { |attendance| attendance.date.strftime("%b").downcase }

        formatted_data = {}
        monthly_attendance_data.each do |month, attendances|
          formatted_data[month] = []
          attendances.each do |attendance|
            attendance_data = {
              date: attendance.date.to_date.to_s,
              attendance_info: {
                id: attendance.id,
                log: []
              }
            }

            attendance.punch_in_times.each_with_index do |punch_in_time, index|
              punch_in = punch_in_time.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
              punch_out = attendance.punch_out_times[index]&.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
              attendance_data[:attendance_info][:log] << {
                punch_in_times: punch_in,
                punch_out_times: punch_out
              }
            end

            total_time = calculate_total_time(attendance.punch_in_times, attendance.punch_out_times)
            gross_hours = hours_worked_today(attendance.punch_in_times, attendance.punch_out_times)

            regularization_data = fetch_regularization_data(attendance.regularizations)

            attendance_data[:attendance_info].merge!(
              status: attendance.status,
              address: attendance.address,
              punch_type: attendance.punch_type,
              total_time: total_time,
              gross_hours: gross_hours,
              user_id: attendance.user_id,
              created_at: attendance.created_at,
              updated_at: attendance.updated_at,
              regularization_log: regularization_data
            )

            formatted_data[month] << attendance_data
          end
        end
        render json: formatted_data
      end

     def render_month_attendance_log(user, month, year)
        start_date = Date.new(year, month, 1)
        end_date = start_date.end_of_month
        monthly_attendance_data = user.attendances.where(date: start_date..end_date)
                                                    .sort_by { |x| x.date }
                                                    .group_by { |attendance| attendance.date.strftime("%Y-%m-%d") }

        formatted_data = {
          Date::ABBR_MONTHNAMES[month].downcase => []
        }

        monthly_attendance_data.each do |date, attendances|
          formatted_data[Date::ABBR_MONTHNAMES[month].downcase] << {
            date: date,
            attendance_info: {
              id: attendances.first.id,
              log: []
            }
          }

          total_time = calculate_month_total_time(attendances)

          attendances.each do |attendance|
            attendance.punch_in_times.each_with_index do |punch_in_time, index|
              formatted_data[Date::ABBR_MONTHNAMES[month].downcase].last[:attendance_info][:log] << {
                punch_in_times: punch_in_time,
                punch_out_times: attendance.punch_out_times[index]
              }
            end
          end
          
          formatted_data[Date::ABBR_MONTHNAMES[month].downcase].last[:attendance_info].merge!(
            status: attendances.first.status,
            address: attendances.first.address,
            punch_type: attendances.first.punch_type,
            total_time: total_time,
            user_id: attendances.first.user_id,
            created_at: attendances.first.created_at,
            updated_at: attendances.first.updated_at
          )
        end

        render json: formatted_data
      end

     def render_month_attendance_log_for_current_user(month, year)
      start_date = Date.new(year, month, 1)
        end_date = start_date.end_of_month
        monthly_attendance_data = @current_user.attendances.where(date: start_date..end_date)
                                                    .sort_by { |x| x.date }
                                                    .group_by { |attendance| attendance.date.strftime("%Y-%m-%d") }

        formatted_data = {
          Date::ABBR_MONTHNAMES[month].downcase => []
        }

        monthly_attendance_data.each do |date, attendances|
          formatted_data[Date::ABBR_MONTHNAMES[month].downcase] << {
            date: date,
            attendance_info: {
              id: attendances.first.id,
              log: []
            }
          }

          total_time = calculate_month_total_time(attendances)

          attendances.each do |attendance|
            attendance.punch_in_times.each_with_index do |punch_in_time, index|
              formatted_data[Date::ABBR_MONTHNAMES[month].downcase].last[:attendance_info][:log] << {
                punch_in_times: punch_in_time,
                punch_out_times: attendance.punch_out_times[index]
              }
            end
          end
          
          formatted_data[Date::ABBR_MONTHNAMES[month].downcase].last[:attendance_info].merge!(
            status: attendances.first.status,
            address: attendances.first.address,
            punch_type: attendances.first.punch_type,
            total_time: total_time,
            user_id: attendances.first.user_id,
            created_at: attendances.first.created_at,
            updated_at: attendances.first.updated_at
          )
        end

        render json: formatted_data
     end
    end
  end
end
