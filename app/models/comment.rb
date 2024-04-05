class Comment < ApplicationRecord
  # Assoiciations
  belongs_to :user, optional: true
  belongs_to :organization, optional: true
  belongs_to :request
end
