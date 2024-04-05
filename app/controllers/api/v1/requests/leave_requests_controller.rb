module Api
	module V1
		module Requests
			class LeaveRequestsController < ApplicationController

				def create
					leave = LeaveRequest.new(leave_params)
					if leave.save
						render json: { leave: LeaveSerializer.new(leave) }, status: :ok
						else
						render json: {message: "can't apply for leave"}
					end
				end

				private
				def leave_params
					params.require(:leave).permit(:start_date, :end_date, :leave_type, :reason, :start_time, :end_time, :paid_leave, :status, :user_ids )
				end
   
			end
		end
	end
end
