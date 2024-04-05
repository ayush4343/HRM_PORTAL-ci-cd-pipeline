class LeaveRequest < ApplicationRecord

	enum leave_type: [:full_day, :half_day, :partial_day]
end
