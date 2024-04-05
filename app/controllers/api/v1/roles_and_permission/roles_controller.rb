module Api::V1
  module RolesAndPermission
    class RolesController < ApplicationController
      before_action :authorize_request
      before_action :set_role, only: [:add_permissions, :permissions]
      def index
        if @current_user.class.name.eql? 'Organization'
          @roles = @current_user.roles.all
          render json: @roles, each_serializer: RoleSerializer
        elsif @current_user.class.name.eql? 'User'
           @organizations = @current_user.organization
           @roles = @organizations.roles.all
            render json: @roles, each_serializer: RoleSerializer
        else
          render json:  {message: "You are not authorized to get role"}, status: :unprocessable_entity
        end
      end

      def create
        if @current_user.class.name.eql? 'Organization'
          @role = @current_user.roles.new(role_params)
          @role.name.capitalize!
          if @role.save
            render json: { message: "Role created sucessfully", role: @role}, status: :created
          else
            render json: {error: format_activerecord_errors(@role.errors.full_messages)},
            status: :unprocessable_entity
          end
        else
          render json:  {message: "You are not authorized to create role"}, status: :unprocessable_entity
        end
      end

      def add_permissions
        permission_ids = params[:permission_ids]
        if permission_ids&.present?
          existing_permission_ids = @role.permissions.pluck(:id)
          new_permission_ids = permission_ids - existing_permission_ids
          if new_permission_ids.any?
            new_permissions = Permission.where(id: new_permission_ids)
            @role.permissions << new_permissions
             render json: @role, each_serializer: RoleSerializer, status: :created
          else
            render json: { message: 'Permissions already exist in role' }
          end
        else
          render json: { error: 'Permission IDs are required' }, status: :unprocessable_entity
        end
      end

      def permissions
        render json: @role.permissions
      end
      private

      def set_role
        @role = Role.find(params[:id])
      end

      def role_params
        params.require(:role).permit(:name)
      end

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
