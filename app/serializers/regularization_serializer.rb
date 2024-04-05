class RegularizationSerializer < ActiveModel::Serializer
	attributes :id, :reason, :status, :date, :attendance_id, :user_ids, :requested_by, :action_by, :reg_punch_in_times, :reg_punch_out_times,  :created_at, :updated_at
end