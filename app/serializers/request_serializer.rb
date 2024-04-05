class RequestSerializer < ActiveModel::Serializer
  HOST = ENV['base_url']
  attributes :id, :title, :type_of_concern,  :description, :status, :created_at, :updated_at, :created_by,:department, :concern, :ticket_images , :comments


  attribute :created_by do |object|
   user =  object&.object&.user
     { id: user&.id, name: user&.first_name + " "+ user&.last_name} if user
  end

  def department
    Department.find_by(id: object.department_id)
  end

  def concern 
    Concern.find_by(id: object.concern_related)
  end

  def ticket_images
    return [] unless object.ticket_images.attached?
    object.ticket_images.map do |image|
      {
        file_name: image.blob.filename,
        content_type: image.blob.content_type,
        id: image.id,
        url: Rails.application.routes.url_helpers.rails_blob_url(image),
        blob_id: image.blob.id,
      }
    end
  end

  belongs_to :comments, serializer: CommentSerializer
end
