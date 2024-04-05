class RegularizationLogSerializer < ActiveModel::Serializer
	attributes :id, :punch_in_times, :punch_out_times, :created_at, :updated_at
end