require 'rails_helper'
require 'faker'


RSpec.describe Api::V1::Authorizations::OrganizationController, type: :request do

  describe "POST /api/v1/create organization" do
    context 'when creating a organization' do
      let(:params) do 
        {
          organization: {
            email: Faker::Internet.email,
            password: "Pass@123456",
            company_name: Faker::Company.name,
            contact: Faker::PhoneNumber.phone_number,
            website: Faker::Internet.url,
            owner_name: "x avier",
            address: "xyz add",
            activated: "false"
          }
        }
      end

      it "creates a user successfully"  do
        post "/api/v1/organization", params: params
        json_data = JSON.parse(response.body)
        expect(json_data["organization"]["email"]).to eq(params[:organization][:email])
        expect(json_data["organization"]["contact"]).to eq(params[:organization][:contact])
        expect(json_data["organization"]["website"]).to eq(params[:organization][:website])
        expect(json_data["message"]).to eq("organization created succesfully")
        expect(response).to have_http_status(201)      
      end

      let(:invalid_organization_params) do
        {
          organization: {
            email: Faker::Internet.email,
            password: Faker::Internet.password
          }
        }
      end

      it "fails to create a organization due to missing params" do
        post '/api/v1/organization', params: invalid_organization_params
        json_data = JSON.parse(response.body)
        expect(response).to have_http_status(422)
        expect(json_data['message']).to eq("Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character")
      end

      let(:invalid_email) do
        {
          organization: {
            email: Faker::Internet.email,
            password: "Pass@2345",
            company_name: Faker::Company.name,
            contact: Faker::PhoneNumber.phone_number,
            website: Faker::Internet.url,
            activated: "false"
          }
        }
      end

      it "fails to create a organization due to invalid params" do
        post '/api/v1/organization', params: invalid_email
        json_data = JSON.parse(response.body)
        expect(json_data["error"]).to eq(["Address can't be blank", "Owner name can't be blank"])
        expect(response).to have_http_status(422)
      end

      let(:invalid_email_params) do
        {
          organization: {
            email: "abc@gmail.com",
            password: Faker::Internet.password,
            company_name: Faker::Company.name,
            contact: Faker::PhoneNumber.phone_number,
            website: Faker::Internet.url,
            activated: "false"
          }
        }
      end

      it "fails to create a organization due to invalid email" do
        @organization = FactoryBot.create(:organization)
        @role = FactoryBot.create(:role, organization_id: @organization.id)
        @user = FactoryBot.create(:user, email: Faker::Internet.email, role_id: @role.id)    
        post '/api/v1/organization', params: invalid_email_params
        json_data = JSON.parse(response.body)
        expect(json_data["message"]).to eq("Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character")      end
    end
  end

  describe "GET /api/v1/show_all_employee" do
    context 'when show all employee' do
      it 'for valid params' do
        @organization = FactoryBot.create(:organization)
        @role = FactoryBot.create(:role, organization_id: @organization.id)
        @user = FactoryBot.create(:user, email: Faker::Internet.email, role_id: @role.id, organization_id: @organization.id)
        @token = JsonWebToken.encode(organization_id: @organization.id)
        
        get '/api/v1/show_all_employee', headers: {token: @token}
        json_data = JSON.parse(response.body)
        
        expect(response).to have_http_status(200)
        expect(json_data.count).to eq(1)
      end
      it 'for unauthorised user' do
        @organization = FactoryBot.create(:organization)
        @role = FactoryBot.create(:role, organization_id: @organization.id)
        @user = FactoryBot.create(:user, email: Faker::Internet.email, role_id: @role.id, organization_id: @organization.id)
        @token = JsonWebToken.encode(user_id: @user.id)
        
        get '/api/v1/show_all_employee', headers: {token: @token}
        json_data = JSON.parse(response.body)
        
        expect(response).to have_http_status(422)
        expect(json_data['message']).to eq("You are not authorized")
      end
    end
  end

  describe "POST /api/v1/organization_change_password" do
    let!(:organization) { FactoryBot.create(:organization, password: "Pass@1234") }
    let!(:role) { FactoryBot.create(:role, organization_id: organization.id) }
    let!(:user) { FactoryBot.create(:user, email: Faker::Internet.email, role_id: role.id, organization_id: organization.id) }
    let!(:token) { JsonWebToken.encode(organization_id: organization.id) }

    context 'when change password' do
      it 'when entres correct change password params' do
        post "/api/v1/organization_change_password", headers: {token: token}, params: { old_password: "Pass@1234", new_password: "Pass@123456", confirm_password: "Pass@123456"}
        json_data = JSON.parse(response.body)
        expect(json_data['data']["id"]).to eq(organization.id)
        expect(json_data["message"]).to eq('Password Updated Successfully') 
        expect(response).to have_http_status(200)
      end

      it 'when entres incorrect confirm password' do
        post "/api/v1/organization_change_password", headers: {token: token}, params: { old_password: "Pass@1234", new_password: "Pass@12345", confirm_password: "Pass123456"}
        json_data = JSON.parse(response.body)
        expect(json_data["message"]).to eq('New password and confirm password should be same.')
        expect(response).to have_http_status(422)
      end

      it 'when entres incorrect new password' do
        post "/api/v1/organization_change_password", headers: {token: token}, params: { old_password: "Pass@1234", new_password: "12345"}
        json_data = JSON.parse(response.body)  
        expect(json_data["message"]).to eq('Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character')
        expect(response).to have_http_status(422)
      end

      it 'when entres incorrect old password' do   
        post "/api/v1/organization_change_password", headers: {token: token}, params: { old_password: "Pass@123", new_password: "Pass12345"}
        json_data = JSON.parse(response.body)    
        expect(json_data["message"]).to eq('Please enter a correct old password.')
        expect(response).to have_http_status(422)
      end

      it 'when no record found' do    
        post "/api/v1/organization_change_password", headers: {token: token}
        json_data = JSON.parse(response.body)   
        expect(json_data["message"]).to eq('Record Not Found.')
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "POST /api/v1/organization_forgot_password" do
    let!(:organization) { FactoryBot.create(:organization, password: "Pass@1234") }
    let!(:role) { FactoryBot.create(:role, organization_id: organization.id) }
    let!(:user) { FactoryBot.create(:user, email: Faker::Internet.email, role_id: role.id, organization_id: organization.id) }
    let!(:token) { JsonWebToken.encode(organization_id: organization.id) }
    context 'when organization is not registered' do
      it 'it returns error message' do
        
        post "/api/v1/organization_forgot_password", params: { email: "xyz@gmail.com"}
        json_data = JSON.parse(response.body)

        expect(json_data['message']).to eq('email_not_register')
        expect(response).to have_http_status(422)
      end
    end
    context 'when valid  params for forgot password' do
      it 'it  send otp succesfully' do
        
        post "/api/v1/organization_forgot_password", params: { email: organization.email}
        json_data = JSON.parse(response.body)

        expect(json_data['message']).to eq('otp send successfully')
        expect(json_data['organization']).to be_present
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "POST /api/v1/organization_reset_password_verify_email" do
    let!(:organization) { FactoryBot.create(:organization, password: "Pass@1234") }
    let!(:role) { FactoryBot.create(:role, organization_id: organization.id) }
    let!(:user) { FactoryBot.create(:user, email: Faker::Internet.email, role_id: role.id, organization_id: organization.id) }
    let!(:token) { JsonWebToken.encode(organization_id: organization.id) }
    let!(:random_number) { 4.times.map { rand(1..9) }.join }

      it 'for valid reset password verify email params' do
        organization.organization_otps.create(verification_code: random_number)
        post "/api/v1/organization_reset_password_verify_email", params: { email: organization.email, otp: random_number}
        json_data = JSON.parse(response.body)
        expect(json_data['token']).to be_present
        expect(json_data['message']).to eq('email_verified_success')
        expect(response).to have_http_status(200)
      end

      it 'for invalid verification code' do
        organization.organization_otps.create(verification_code: random_number)
        post "/api/v1/organization_reset_password_verify_email", params: { email: organization.email}
        json_data = JSON.parse(response.body)
        
        expect(json_data['message']).to eq('verification_code_incorrect')
        expect(response).to have_http_status(422)
      end

      it 'for verification code not present in params' do
        post "/api/v1/organization_reset_password_verify_email", params: { email: organization.email}
        json_data = JSON.parse(response.body)
        expect(json_data['message']).to eq('verification_code_incorrect')
        expect(response).to have_http_status(422)
      end

      it 'returns error message for user not present' do
        
        post "/api/v1/organization_reset_password_verify_email", params: { email: "xyz@gmail.com"}
        json_data = JSON.parse(response.body)

        expect(json_data['message']).to eq('user_not_found_with_given_email')
        expect(response).to have_http_status(422)
      end
  end

  describe "POST /api/v1/organization_reset_password" do
    let!(:organization) { FactoryBot.create(:organization, password: "Pass@1234") }
    let!(:role) { FactoryBot.create(:role, organization_id: organization.id) }
    let!(:user) { FactoryBot.create(:user, email: Faker::Internet.email, role_id: role.id, organization_id: organization.id) }
    let!(:token) { JsonWebToken.encode(organization_id: organization.id) }
    it 'for invalid new password' do
      post "/api/v1/organization_reset_password", headers: { token: token}, params: { new_password: "Pass@12345", confirm_password: "Pass@12345"}
      json_data = JSON.parse(response.body)
      expect(json_data['message']).to eq('New Password set Successfully.')
      expect(response).to have_http_status(200)
    end

    it 'for same old and new password' do
      post "/api/v1/organization_reset_password", headers: { token: token}, params: { new_password: "Pass@1234", confirm_password: "Pass@1234"}
      json_data = JSON.parse(response.body)
      expect(json_data['error']).to eq('New Password should not be same as old password.')
      expect(response).to have_http_status(422)
    end

    it 'for invalid new password' do
      post "/api/v1/organization_reset_password", headers: { token: token}, params: { new_password: "1234", confirm_password: "1234"}
      json_data = JSON.parse(response.body)   
      expect(json_data['error']).to eq('Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character')
      expect(response).to have_http_status(422)
    end

    it 'for diffrent new and confirm password' do
      post "/api/v1/organization_reset_password", headers: { token: token}, params: { new_password: "Pass@1234", confirm_password: "Pass@123"}
      json_data = JSON.parse(response.body)    
      expect(json_data['error']).to eq('New password and confirm password should be same.')
      expect(response).to have_http_status(422)
    end
  end

  describe "POST /api/v1/create_geofencing" do
    let!(:organization) { FactoryBot.create(:organization) }
    let!(:token) { JsonWebToken.encode(organization_id: organization.id) }
    context 'when create organization wise geofencing' do
      let(:valid_params) do 
                {
            data: {
                latitude: "22.7533",
                longitude: "75.8937",
                radius: "200"
            }
        }
      end

      it "creates a geofencing successfully"  do
        post "/api/v1/create_geofencing", headers: {token: token}, params: valid_params
        json_data = JSON.parse(response.body)
        expect(response).to have_http_status(201)      
      end
      let(:in_valid_params) do 
                {
            data: {
                latitude: "",
                longitude: "",
                radius: ""
            }
        }
      end

      it "creates a geofencing unsuccessfully"  do
        post "/api/v1/create_geofencing", headers: {token: token}, params: in_valid_params
        json_data = JSON.parse(response.body)
        expect(response).to have_http_status(422)      
      end
    end
  end
end
