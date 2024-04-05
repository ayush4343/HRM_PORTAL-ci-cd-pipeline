class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :email, :company_name, :website, :contact, :owner_name, :address, :activated
end