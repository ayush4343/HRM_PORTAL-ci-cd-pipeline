module Api::V1
  module Requests
    class RequestsController < ApplicationController
      before_action :authorize_request, only: [:create, :update, :index, :show, :dashboard, :show_departments, :escalate_request, :comments, :get_all_escalate_request]
      protect_from_forgery with: :exception, except: [:create, :update, :dashboard, :escalate_request, :comments, :get_all_escalate_request]

      include Response
      def create
        return render_unauthorized if @current_user.instance_of?(Organization)

        department = @current_user.organization.departments.find_by(id: params.dig(:request, :department_id))
        return render_invalid_department unless department.present?

        concern = Concern.find_by(id: params.dig(:request, :concern_related))
        return render_invalid_concern unless concern&.department_id == department.id

        request = @current_user.requests.new(request_params.except(:ticket_images))
        attach_ticket_images(request, params[:request][:ticket_images]) if params.dig(:request, :ticket_images).present?

        if request.save
          render_created(request)
        else
          render_error(request)
        end
      end

      

      def update
        begin
        if @current_user.class.name.eql? 'Organization'
          request = Request.find(params[:id])
          if params[:data][:status] == "in_progress" || params[:data][:status] == "resolved"
            request.update(status: params[:data][:status])
            render json: { request: RequestSerializer.new(request) }, status: :ok
          else
            render json: { message: "You are not allowed to update the request with the specified status" }, status: :unprocessable_entity
          end
        elsif @current_user.class.name.eql?('User') && !@current_user.role.name.eql?('Employee') && @current_user.role.permissions.pluck(:name).include?("update_ticket")
          request = Request.find(params[:id])
          if request.department.roles.pluck(:id).include?(@current_user.role_id) && request.department.organization_id == @current_user.organization.id && !params[:data][:status].eql?('open')
             request.update(status: params[:data][:status])  
             render json: { request: RequestSerializer.new(request) }, status: :ok
          else
             render json: { message: "You don't have permissions to change the status"}, status: :unprocessable_entity
          end
        elsif @current_user&.role.name ==  "Employee"
          if params[:data][:status] == "reopened"
            request = @current_user&.requests.find(params[:id])
            request.update(status: params[:data][:status])
            render json: { request: RequestSerializer.new(request) }, status: :ok
          else
            render json: { message: "You are not allowed to update the request with the specified status" }, status: :unprocessable_entity
          end
        else
          raise StandardError, "Invalid user role"
        end
        rescue Exception => e
          render json: {error: e.to_s}
        end
      end

      def index
        if @current_user.class.name.eql? 'Organization'
           @requests = Request.where(department_id: @current_user.departments, status: params[:status], type_of_concern: params[:type_of_concern])
         render json: ActiveModelSerializers::SerializableResource.new(
          @requests,
          each_serializer: RequestSerializer,
          meta: { message: "Success." }
          ).as_json, status: :ok
        elsif @current_user.class.name.eql?('User') && !@current_user.role.name.eql?('Employee')
          @requests = []
          @current_user.organization.departments.each do |dept|
            @requests << Request.where(department_id: dept.id, status: params[:status], type_of_concern: params[:type_of_concern]) if dept.department_roles&.pluck(:role_id).include?(@current_user.role_id)
          end
    
          render json: ActiveModelSerializers::SerializableResource.new(
          @requests.flatten,
          each_serializer: RequestSerializer,
          meta: { message: "Success." }
          ).as_json, status: :ok
        elsif @current_user.role.name.eql?('Employee')
         @requests = Request.where(user_id: @current_user.id, status: params[:status], type_of_concern: params[:type_of_concern])
         render json: ActiveModelSerializers::SerializableResource.new(
          @requests,
          each_serializer: RequestSerializer,
          meta: { message: "Success." }
          ).as_json, status: :ok
        end
      end

      def show
        request = Request.find(params[:id])
        render json: { request: RequestSerializer.new(request) }, status: :ok
      end

      def dashboard
        if @current_user.class.name.eql?('Organization')
          department_ids = @current_user.departments.ids
          request = Request.where(department_id: department_ids)
        elsif @current_user.class.name.eql?('User') && !@current_user.role.name.eql?('Employee')
          department_ids = DepartmentRole.where(role_id: @current_user.role_id).pluck(:department_id) & @current_user.organization.departments.ids
          request = Request.where(department_id: department_ids)
        elsif @current_user.role.name.eql?('Employee')
          request = Request.where( user_id: @current_user.id)
        end
        total = request.count
        resolved = request.resolved_request.count
        queries_tickets = request.queries_ticket.count
        complaint_tickets = request.complaint_ticket.count
        request_tickets = request.request_ticket.count

        resolved_rate = total != 0 ? ((resolved * 100) / total.to_f).round(2) : 0

        render json: { resolved_rate: resolved_rate, total: total, Queries_tickets: queries_tickets, Complaint_tickets: complaint_tickets, Request_tickets: request_tickets }
      end

      def show_departments
       if @current_user.class.name.eql? 'User'
          @departments = Department&.where(organization_id: @current_user.organization_id)&.pluck(:id, :name).map { |id, name| { id: id, name: name } }
          render json: @departments
        elsif @current_user.class.name.eql? 'Organization'
          @departments = Department&.where(organization_id: @current_user.id)&.pluck(:id, :name).map { |id, name| { id: id, name: name } }
          render json: @departments
        else
          render json: {message: "Please provide Valid user"}, status: :unprocessable_entity
       end
      end

      def comments
        if @current_user.class.name.eql? 'User'
          if Request.find(params[:request_id]).present?
            comment = @current_user.comments.create!(body: params[:body], request_id: params[:request_id])
            render json: {comments: CommentSerializer.new(comment)}
          else 
            render json: {message: "Please provide valid request "}
          end
        elsif @current_user.class.name.eql? 'Organization'
          if Request.find(params[:request_id]).present?
            comment = @current_user.comments.create!(body: params[:body], request_id: params[:request_id])
            render json: {comments: CommentSerializer.new(comment)}
          else 
            render json: {message: "Please provide valid request "}
          end
        end
      end
      
      def escalate_request
        if @current_user.class.name.eql?('User') && params[:request_id].present? && @current_user.requests&.ids&.include?(params[:request_id])
          @request = Request.find_by(id: params[:request_id])
          if @request.status.eql?('resolved') 
            @comments = @current_user.comments.create!(body: params[:body], request_id: params[:request_id])
            @request.update_column(:status, 'escalate')
              escalate_data = RequestJob.set(wait_until: 10.seconds.from_now).perform_later(@request, @comments)
              if escalate_data.successfully_enqueued?
               render json: {request: RequestSerializer.new(@request)}, status: :ok
              else
                render json: { message: "Unable to send escalate email #{escalate_data.exception}", status: :unprocessable_entity }
              end
          else
            render json: {message: "Only resolved ticket is escalated"}, status: :unprocessable_entity
          end
        else
          render json: {message: "You are not authorized to change the status"}, status: :unprocessable_entity
        end
      end
      
      def get_all_escalate_request
        @requests = Request.where(user_id: @current_user.id, status: 'escalate') if @current_user.class.name.eql?('User')
        @requests = Request.where(department_id: @current_user.departments, status: 'escalate') if @current_user.class.name.eql? 'Organization'
        render json: ActiveModelSerializers::SerializableResource.new(
        @requests,
        each_serializer: RequestSerializer,
        meta: { message: "Success." }
        ).as_json, status: :ok    
      end

      private

      def render_unauthorized
        render json: { message: "You are not authorized to create a ticket" }, status: :unprocessable_entity
      end

      def render_invalid_department
        render json: { message: "Please select a valid department" }, status: :unprocessable_entity
      end

      def render_invalid_concern
        render json: { message: "Please provide a valid concern" }, status: :unprocessable_entity
      end

      def attach_ticket_images(request, ticket_images)
        ticket_images.each do |icon|
          icon['images'].as_json.each { |image| request.ticket_images.attach(image) }
        end
      end

      def render_created(request)
        render json: { request: RequestSerializer.new(request), message: "Ticket created successfully" }, status: :created
      end

      def render_error(request)
        render json: { message: request.errors.full_messages.join(',') }, status: :unprocessable_entity
      end

      def request_params
        params.require(:request).permit(:title, :description, :status, :department_id, :concern_related, :type_of_concern, ticket_images: [])
      end
    end
  end
end
