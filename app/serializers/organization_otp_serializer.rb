class OrganizationOtpSerializer < ActiveModel::Serializer
  attributes :id, :verification_code, :organization
end