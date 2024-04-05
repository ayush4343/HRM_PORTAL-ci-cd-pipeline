class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name,:middle_name, :phone_number, :gender, :phone_number, :device_token, :device_type, :role, :shift_start, :shift_end, :buffer_time, :shift_mode, :face_enroll

  def face_enroll
    if object.face_enroll.attached?
       Rails.application.routes.url_helpers.rails_blob_url(object.face_enroll)   
    end
  end
end

