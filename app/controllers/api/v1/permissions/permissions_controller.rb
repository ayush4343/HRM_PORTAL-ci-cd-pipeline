module Api::V1
  module Permissions
    class PermissionsController < ApplicationController
      before_action :authorize_request
      def index
        if @current_user.class.name.eql? 'Organization'
          @permissions = Permission.all
          render json: @permissions, each_serializer: PermissionSerializer
        else
         render json: {message: "You are not authorize"}, status: :unprocessable_entity
        end 
      end

      def create
        if @current_user.class.name.eql? 'Organization'
          @permission = Permission.new(permission_params)
          if @permission.save
            render json: { message: "permission created sucessfully", permission: @permission }, status: :created
          else
            render json: {error: format_activerecord_errors(@user.errors.full_messages)},
            status: :unprocessable_entity
          end
        else
          render json: {message: "You are not authorize"}, status: :unprocessable_entity
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
      def permission_params
        params.require(:permission).permit(:name)
      end
    end
  end
end
