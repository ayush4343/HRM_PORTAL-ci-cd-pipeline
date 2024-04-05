class UserOtpSerializer < ActiveModel::Serializer
  attributes :id, :verification_code
end