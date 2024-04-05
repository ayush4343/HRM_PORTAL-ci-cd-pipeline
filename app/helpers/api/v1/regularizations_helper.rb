module  Api::V1::RegularizationsHelper
    def to_utc_time_punch_in(timestamps)
      timestamps.map { |time| Time.parse(time).utc.strftime("%Y-%m-%dT%H:%M:%S.000") }
    end

    def to_utc_time_punch_out(timestamps)
      timestamps.map { |time| Time.parse(time).utc.strftime("%Y-%m-%dT%H:%M:%S.000") }
    end

    def render_regularizations_log_for_current_user(current_user)
      monthly_regularization_data = current_user.regularizations.where("date >= ?", 30.days.ago.beginning_of_day)
                                                        .sort_by { |x| x.date }
                                                        .group_by { |regularization| regularization.date.strftime("%b").downcase }

      formatted_data = {}
      monthly_regularization_data.each do |month, regularizations|
        formatted_data[month] = []
        regularizations.each do |regularization|
          regularizations_data = {
            date: regularization.date.to_date.to_s,
            regularization_info: {
              id: regularization.id,
              log: []
            }
          }

          regularization.reg_punch_in_times.each_with_index do |reg_punch_in_time, index|
            reg_punch_in = reg_punch_in_time.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            reg_punch_out = regularization.reg_punch_out_times[index]&.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            regularizations_data[:regularization_info][:log] << {
              reg_punch_in_times: reg_punch_in,
              reg_punch_out_times: reg_punch_out
            }
          end

          regularizations_data[:regularization_info].merge!(
            status: regularization.status,
            reason: regularization.reason,
            attendance_id: regularization.attendance_id,
            user_id: regularization.user_id,
            date: regularization.date,
            requested_by: regularization.requested_by,
            action_by: regularization.action_by,
            user_ids: regularization.user_ids,
            created_at: regularization.created_at,
            updated_at: regularization.updated_at,
          )

          formatted_data[month] << regularizations_data
        end
      end
       return formatted_data
    end
    def render_regularizations_log_for_assignee(current_user)
      regularizations = Regularization.where(user_ids: [current_user.id])
      monthly_regularization_data = regularizations.where("date >= ?", 30.days.ago.beginning_of_day)
                                                        .sort_by { |x| x.date }
                                                        .group_by { |regularization| regularization.date.strftime("%b").downcase }

      formatted_data = {}
      monthly_regularization_data.each do |month, regularizations|
        formatted_data[month] = []
        regularizations.each do |regularization|
          regularizations_data = {
            date: regularization.date.to_date.to_s,
            regularization_info: {
              id: regularization.id,
              log: []
            }
          }

          regularization.reg_punch_in_times.each_with_index do |reg_punch_in_time, index|
            reg_punch_in = reg_punch_in_time.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            reg_punch_out = regularization.reg_punch_out_times[index]&.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            regularizations_data[:regularization_info][:log] << {
              reg_punch_in_times: reg_punch_in,
              reg_punch_out_times: reg_punch_out
            }
          end

          regularizations_data[:regularization_info].merge!(
            status: regularization.status,
            reason: regularization.reason,
            attendance_id: regularization.attendance_id,
            user_id: regularization.user_id,
            date: regularization.date,
            requested_by: regularization.requested_by,
            action_by: regularization.action_by,
            user_ids: regularization.user_ids,
            created_at: regularization.created_at,
            updated_at: regularization.updated_at,
          )

          formatted_data[month] << regularizations_data
        end
      end
       return formatted_data
    end

    def render_month_regularization_log(user, month, year)
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      monthly_regularization_data = user.regularizations.where(date: start_date..end_date)
                                                    .sort_by { |x| x.date }
                                                    .group_by { |regularization| regularization.date.strftime("%b").downcase }

      formatted_data = {}
      monthly_regularization_data.each do |month, regularizations|
        formatted_data[month] = []
        regularizations.each do |regularization|
          regularizations_data = {
            date: regularization.date.to_date.to_s,
            regularization_info: {
              id: regularization.id,
              log: []
            }
          }

          regularization.reg_punch_in_times.each_with_index do |reg_punch_in_time, index|
            reg_punch_in = reg_punch_in_time.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            reg_punch_out = regularization.reg_punch_out_times[index]&.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            regularizations_data[:regularization_info][:log] << {
              reg_punch_in_times: reg_punch_in,
              reg_punch_out_times: reg_punch_out
            }
          end

          regularizations_data[:regularization_info].merge!(
            status: regularization.status,
            reason: regularization.reason,
            attendance_id: regularization.attendance_id,
            user_id: regularization.user_id,
            date: regularization.date,
            requested_by: regularization.requested_by,
            action_by: regularization.action_by,
            user_ids: regularization.user_ids,
            created_at: regularization.created_at,
            updated_at: regularization.updated_at,
          )

          formatted_data[month] << regularizations_data
        end
      end
       return formatted_data
    end
    def render_month_regularization_log_for_assignee(user, month, year)
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      regularizations = Regularization.where(user_ids: [user.id])
      monthly_regularization_data = regularizations.where(date: start_date..end_date)
                                                    .sort_by { |x| x.date }
                                                    .group_by { |regularization| regularization.date.strftime("%b").downcase }

      formatted_data = {}
      monthly_regularization_data.each do |month, regularizations|
        formatted_data[month] = []
        regularizations.each do |regularization|
          regularizations_data = {
            date: regularization.date.to_date.to_s,
            regularization_info: {
              id: regularization.id,
              log: []
            }
          }

          regularization.reg_punch_in_times.each_with_index do |reg_punch_in_time, index|
            reg_punch_in = reg_punch_in_time.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            reg_punch_out = regularization.reg_punch_out_times[index]&.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
            regularizations_data[:regularization_info][:log] << {
              reg_punch_in_times: reg_punch_in,
              reg_punch_out_times: reg_punch_out
            }
          end

          regularizations_data[:regularization_info].merge!(
            status: regularization.status,
            reason: regularization.reason,
            attendance_id: regularization.attendance_id,
            user_id: regularization.user_id,
            date: regularization.date,
            requested_by: regularization.requested_by,
            action_by: regularization.action_by,
            user_ids: regularization.user_ids,
            created_at: regularization.created_at,
            updated_at: regularization.updated_at,
          )

          formatted_data[month] << regularizations_data
        end
      end
       return formatted_data
    end
end
