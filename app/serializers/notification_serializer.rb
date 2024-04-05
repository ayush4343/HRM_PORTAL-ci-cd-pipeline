class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :subject, :message, :is_read, :is_deleted
end
   