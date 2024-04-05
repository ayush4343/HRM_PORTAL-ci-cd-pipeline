# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

unless AdminUser.find_by(email: 'admin@example.com')
  AdminUser.create!(
    email: 'admin@example.com',
    password: 'password',
    password_confirmation: 'password'
  )  
end
["create_users","update_ticket","update_users","attendance_log", "show_users","regularizations_request"].each do |permission|
  unless Permission.find_by(name: permission)
    Permission.create!(name: permission)
  end
end