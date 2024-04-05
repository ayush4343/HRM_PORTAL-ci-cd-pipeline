Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      namespace :authorizations, path: '' do
        post '/register', to: 'register#create'
        get '/register', to: 'register#show'
        delete '/register', to: 'register#delete'
        post '/authentication', to: 'authentication#login'
        post '/change_password', to: 'passwords#change_password'
        post '/organization', to: 'organization#create'
        post '/forgot_password', to: 'passwords#forgot_password'
        post '/reset_password_verify_email', to: 'passwords#reset_password_verify_email'
        post '/reset_password', to: 'passwords#reset_password'
        post '/organization_change_password', to: 'organization#organization_change_password'
        post '/organization_forgot_password', to: 'organization#organization_forgot_password'
        post '/organization_reset_password_verify_email', to: 'organization#organization_reset_password_verify_email'
        post '/organization_reset_password' , to: 'organization#organization_reset_password'
        post '/create_department', to: 'department#create'
        get '/get_departments', to: 'department#index'
        get '/show_department', to: 'department#show'
        get '/show_concern/:department_id', to: 'department#show_concern', as: :show_concern
        get '/show_all_employee', to: 'organization#show_all_employee'
        post '/create_geofencing', to: 'organization#create_geofencing'
        post 'create_attendance', to: 'attendances#create_attendance'
        patch '/face_enroll/:id', to: "authentication#face_enroll"
        get  'show_all_attendance_log', to: 'attendances#show_all_attendance_log'
        get 'show_month_wise_attendance_log', to: 'attendances#show_month_wise_attendance_log'
      end
      namespace :requests do
        resources :requests
        get '/dashboard', to: "requests#dashboard"
        get '/show_departmemnts', to: "requests#show_departments"
        put '/escalate_request', to: "requests#escalate_request"
        post '/create_comments', to: "requests#comments"
        get '/get_all_escalate_request', to: "requests#get_all_escalate_request"
      end
      namespace :notifications do 
       resources :notifications do
        put :read_all_notificatons, on: :collection
       end
      end
      namespace :roles_and_permission do
        resources :roles do
          member do
            post 'add_permissions'
            get 'permissions'
          end
        end
      end
      namespace :permissions do
        resources :permissions
      end
      namespace :holiday do 
        post '/public_holidays', to: "holidays#public_holidays"
        get '/get_all_public_holidays', to: "holidays#get_all_public_holidays"
      end
      namespace :regularizations do
        resources :regularizations, only: [:create, :update, :index]
        get '/current_user_regularizations', to: "regularizations#current_user_regularizations"
        get '/action_by_user_wise_regularizations', to: "regularizations#action_by_user_wise_regularizations"
        get '/current_user_monthly_regularizations', to: "regularizations#current_user_monthly_regularizations"
        get '/action_by_user_wise_monthly_regularizations', to: "regularizations#action_by_user_wise_monthly_regularizations"
        get '/organization_wise_user_monthly_regularization', to: "regularizations#organization_wise_user_monthly_regularization"
      end
      namespace :requests do
        resources :leave_requests
      end
    end
  end
end
