class GeofencingSerializer < ActiveModel::Serializer
  attributes :id, :latitude, :longitude, :radius
end
   