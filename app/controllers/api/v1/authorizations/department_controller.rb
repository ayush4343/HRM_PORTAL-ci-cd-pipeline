module Api::V1
  module Authorizations
    class DepartmentController < ApplicationController
      before_action :authorize_request, only: [:index, :create]
      def index 
        if @current_user.present? && @current_user.class.name.eql?('Organization')
           @dept = @current_user.departments
           render json: @dept, each_serializer: DepartmentSerializer
        else
          render json: {message: 'please provide a valid organization'}, status: :unprocessable_entity
        end
      end

      def show 
        if params[:id].present?
           department = Department.find_by(id: params[:id])
           render json: department, each_serializer: DepartmentSerializer
        else
           render json: {message: 'department not found!'}, status: :unprocessable_entity
        end
      end

      def show_concern
        if params[:department_id].present?
           @concern = Concern.where(department_id: params[:department_id])
           render json: @concern
        else
           render json: {message: 'department not found!'}, status: :unprocessable_entity
        end
      end

      def create
        return render json: { message: "Only Organization can create departments" }, status: :unprocessable_entity unless @current_user.is_a?(Organization)
        unless @current_user.present? && params[:permissions_to].present? && params[:concerns].present?
          return render json: { message: "Please provide valid data" }, status: :unprocessable_entity
        end
        @department = @current_user.departments.find_or_initialize_by(name: params[:department_name])
        valid_role_ids = params[:permissions_to].select { |role_id| @current_user.roles.exists?(id: role_id) }
        unless valid_role_ids.size == params[:permissions_to].size
          return render json: { message: "roles are not valid" }, status: :unprocessable_entity
        end
        if @department.save
          valid_role_ids.each do |role_id|
            @department.department_roles.find_or_create_by(role_id: role_id)
          end
          params[:concerns].each do |concern_name|
            @department.concerns.find_or_create_by(name: concern_name)
          end
          render json: { department: DepartmentSerializer.new(@department) }, status: :created
        else
          render json: { error: format_activerecord_errors(@department.errors.full_messages) }, status: :unprocessable_entity
        end
      end

      private
        def format_activerecord_errors(errors)
            result = []
            errors.each do |error|
              result << error
            end
            result
        end
    end
  end
end
