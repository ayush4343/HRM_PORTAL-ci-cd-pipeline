class DepartmentSerializer < ActiveModel::Serializer
  attributes :id, :name, :permission, :concerns
  def permission
    object.roles
  end
  def concerns 
    object.concerns
  end
end
   