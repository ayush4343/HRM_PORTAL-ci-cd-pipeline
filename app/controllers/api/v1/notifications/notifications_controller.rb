
module Api::V1
  module Notifications
    class NotificationsController < ApplicationController
      before_action :authorize_request, only: [:index, :show, :read_all_notificatons, :show, :destroy]
      include Response

      def index
        if params[:page].present?
          notification_messages = Notification.where(recipient_id: @current_user.id).order(id: :desc).page(params[:page]).per(10)
        else
          notification_messages = Notification.where(recipient_id: @current_user.id).order(id: :desc)
        end
        render json: notification_messages, 
         each_serializer: NotificationSerializer,
         meta: {
           notification_count: Notification.where(recipient_id: @current_user.id).not_readed.count,
           message: "List of notifications."
         },
         meta_key: 'meta',
         status: :ok
      end


      def read_all_notificatons
        if params[:data].present? && params[:data][:ids].present?
          notifications = Notification.where(id: params[:data][:ids])
          notifications.update_all(is_read: true)

          render json: ActiveModelSerializers::SerializableResource.new(
            notifications.order(id: :desc),
            each_serializer: NotificationSerializer,
            meta: { message: "Success." }
          ).as_json, status: :ok
        else
          render json: { message: 'Something went wrong, please provide ids..!' }, status: :unprocessable_entity
        end
      end


      def show
        notification = Notification.find(params[:id])
        notification.update_column(:is_read, true)
        render json: NotificationSerializer.new(notification, meta: {
                      message: "Success."}).serializable_hash, status: :ok
      end


      def destroy
        notification = Notification.find(params[:id])
        if notification.update_column(:is_deleted, true)
          render json: {message: "Deleted Successfully."}, status: :ok
        else
         render json: {error: format_activerecord_errors(notification.errors.full_messages)},
            status: :unprocessable_entity
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
