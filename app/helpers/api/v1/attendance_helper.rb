module  Api::V1::AttendanceHelper

   def hours_worked_today(punch_in_times, punch_out_times, only_hours = nil)
     diff_time = TimeDifference.between(punch_in_times.first , (punch_out_times.last || punch_in_times.last)).in_seconds
    if diff_time > 0
      hours = (diff_time / 3600).to_i
      minutes = ((diff_time % 3600) / 60).to_i
      seconds = (diff_time % 60).to_i

      if only_hours
        return hours
      else
        return format('%02d:%02d:%02d', hours, minutes, seconds)
      end
    else
      return only_hours ? 0 : "00:00:00"
    end
   end


  def calculate_total_time(punch_in_times, punch_out_times)
    @total_punch_in_time = 0
    @total_punch_out_time = 0

    if punch_in_times&.length == punch_out_times&.length
      punch_in_times.each do |punch_in_time|
        punch_in = Time.parse(punch_in_time.to_s)
        @total_punch_in_time += punch_in.to_i
      end
    else
      punch_in_times[0...-1]&.each do |punch_in_time|
        punch_in = Time.parse(punch_in_time.to_s)
        @total_punch_in_time += punch_in.to_i
      end
    end

    punch_out_times&.each do |punch_out_time|
      punch_out = Time.parse(punch_out_time.to_s)
      @total_punch_out_time += punch_out.to_i
    end

    if @total_punch_out_time > 0
      total_time = @total_punch_out_time - @total_punch_in_time
      format_total_time(total_time)
    end
  end

  def calculate_month_total_time(attendances)
    total_time = 0
    attendances.each do |attendance|
      attendance.punch_in_times.each_with_index do |punch_in_time, index|
        punch_in = Time.parse(punch_in_time.to_s)
        punch_out_time = attendance.punch_out_times[index].to_s
        punch_out = punch_out_time.present? ? Time.parse(punch_out_time) : nil
        if punch_out
          total_time += punch_out.to_i - punch_in.to_i
        end
      end
    end
    format_total_time(total_time)
  end
   
  def format_total_time(total_time)
    total_hours = total_time / 3600
    total_minutes = (total_time % 3600) / 60
    total_seconds = total_time % 60
    "%02d:%02d:%02d" % [total_hours, total_minutes, total_seconds]
  end

  def action_type
    data = @current_user.attendances.where(date: Date.today).first
    if data.nil? || data&.punch_in_times.nil?
      if @current_user.shift_mode == "fixed" && (@current_user.shift_start + @current_user.buffer_time).to_s.split[1] >= Time.now.utc.to_s.split[1]
        @status = "on_time"
      elsif @current_user.shift_mode == "flexible" && (@current_user.shift_end + @current_user.buffer_time).to_s.split[1] >= Time.now.utc.to_s.split[1]
        @status = "on_time"
      else
        @status = "late"
      end
      return "punch_in"
    elsif !data&.punch_out_times.present?
      return "punch_out"
    elsif data.punch_in_times.split.last.last < data.punch_out_times.split.last.last
      return "punch_in"
    else
      return "punch_out"
    end
  end

  def action_valid?(action)
    %w[punch_in punch_out].include?(action)
  end

  def fetch_regularization_data(regularizations)
    regularization_data = {
      log: [],
    }
    regularizations.each do |reg|
      if reg.reg_punch_in_times.present? && reg.reg_punch_out_times.present?
          reg.reg_punch_in_times.each_with_index do |reg_punch_in_time, index|
          reg_punch_in = reg_punch_in_time.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
          reg_punch_out = reg.reg_punch_out_times[index]&.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
          regularization_data[:log] << {
            reg_punch_in_times: reg_punch_in,
            reg_punch_out_times: reg_punch_out
          }
        end
      end
        regularization_data.merge!(
          status: reg.status,
          reason: reg.reason,
          attendance_id: reg.attendance_id,
          user_id: reg.user_id,
          date: reg.date,
          requested_by: reg.requested_by,
          action_by: reg.action_by,
          user_ids: reg.user_ids,
          created_at: reg.created_at,
          updated_at: reg.updated_at,
        )
    end

    regularization_data
  end
end
