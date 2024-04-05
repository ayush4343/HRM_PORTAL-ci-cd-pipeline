class User < ApplicationRecord
  
  has_secure_password

  # attechment
  has_one_base64_attached :face_enroll

  # Assoiciations
  has_many :user_otps, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :regularizations, dependent: :destroy
  has_many :requests, dependent: :destroy
  belongs_to :organization, optional: true
  belongs_to :role

  # Validation
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, :gender, :phone_number, presence: true
  validates :shift_start, :shift_end, :buffer_time, :shift_mode , presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,
            length: { minimum: 6 },
            if: -> { new_record? || !password.nil? }
  before_validation :downcase_email

# enum
  enum gender: [:male, :female, :other]
  enum device_type: [:android, :ios]
  enum shift_mode: [:fixed, :flexible]

 # callback
  before_save :set_type
  
  def downcase_email
    self.email = email.downcase if email.present?
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save
  end
  private
  def set_type
    self.type = 'User'
  end
end
