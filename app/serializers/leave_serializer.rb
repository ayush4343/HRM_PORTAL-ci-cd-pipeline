class LeaveSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :leave_type, :user_ids, :reason, :start_time, :end_time, :status, :paid_leave
end
   