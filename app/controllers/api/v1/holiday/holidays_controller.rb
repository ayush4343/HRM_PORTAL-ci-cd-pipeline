
module Api::V1
  module Holiday
    class HolidaysController < ApplicationController
      before_action :authorize_request

      # code by Mahendra Singh
      def public_holidays
        if authorized_to_create_public_holiday?
          @holiday = @current_user.public_holidays.new(public_holiday_params)
          @holiday.save
          assign_holiday_to_user_or_organization
          render json: { message: "Public holiday created" }, status: :created
        else
          render_unauthorized_error
        end
      end

      def get_all_public_holidays
        @holiday = load_holidays_for_current_user
        render json: @holiday if @holiday
      end

      private

      def authorized_to_create_public_holiday?
        @current_user.is_a?(Organization) ||
          (@current_user.is_a?(User) && admin_or_has_permission?("create_public_holidays"))
      end

      def admin_or_has_permission?(permission)
        @current_user.type.eql?('User') &&
          !@current_user.role.name.eql?('Employee') &&
          @current_user.role.permissions.pluck(:name).include?(permission)
      end

      def assign_holiday_to_user_or_organization
        if @current_user.is_a?(Organization)
          @current_user.public_holidays << @holiday
        elsif @current_user.is_a?(User)
          @current_user.organization.public_holidays << @holiday
        end
      end

      def load_holidays_for_current_user
        @current_user.type.eql?('Organization') ? @current_user.public_holidays : @current_user.organization.public_holidays if @current_user
      end

      def public_holiday_params
        params.require(:public_holiday).permit(:name, :start_date, :end_date)
      end

      def render_unauthorized_error
        render json: { message: 'You are not authorized to create public holidays' }, status: :unprocessable_entity
      end
    end
  end
end


# module Api::V1
#   module Holiday
#     class HolidaysController < ApplicationController
#       before_action :authorize_request
#       def public_holidays
#         if @current_user.class.name.eql?('Organization')
#         # if @current_user.type.eql?('Organization')
#           @holiday = PublicHoliday.new(public_holiday_params)
#           @holiday.save
#           @current_user.public_holidays << @holiday
#           render json: {message: "Public holiday created"}, status: :created
#         elsif @current_user.type.eql?('User') && !@current_user.role.name.eql?('Employee') && @current_user.role.permissions.pluck(:name).include?("create_public_holidays")
#           @holiday = PublicHoliday.new(public_holiday_params)
#           @holiday.save
#           @current_user.organization.public_holidays << @holiday
#           render json: {message: "Public holiday created"}, status: :created
#         else
#           render json: { message: 'You are not authorized to create public holidays' }, status: :unprocessable_entity
#           return
#         end
#       end

#       def get_all_public_holidays
#         @holiday = @current_user.public_holidays if @current_user.type.eql?('Organization')
#         @holiday = @current_user.organization.public_holidays if @current_user.type.eql?('User')
#         if @holiday
#           render json: @holiday
#         end
#       end

#       private
#       def public_holiday_params
#         params.require(:public_holiday).permit(:name, :start_date, :end_date)
#       end
#       def format_activerecord_errors(errors)
#         result = []
#         errors.each do |error|
#           result << error
#         end
#         result
#       end
#     end
#   end
# end


