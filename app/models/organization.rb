class Organization < ApplicationRecord
  has_secure_password
  # Validations
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :company_name, presence: true
  validates :website, presence: true
  validates :contact, presence: true
  validates :contact, uniqueness: { message: :uniqueness }, if: proc { |f| f.contact.present? }
  validates :address, presence: true
  validates :owner_name, presence: true
  enum device_type: [:android, :ios]


  # Assoiciations
  has_many :users, dependent: :destroy
  has_many :organization_otps, dependent: :destroy
  has_many :departments, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :geofencings, dependent: :destroy
  has_and_belongs_to_many :public_holidays, dependent: :destroy, join_table: :organizations_public_holidays
  
  # Callbackes
  before_validation :downcase_email
  before_save :set_type

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
  def set_type
    self.type = 'Organization'
  end
end
