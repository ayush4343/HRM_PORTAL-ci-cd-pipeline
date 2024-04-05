class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :user, :organization, :created_at 
end
