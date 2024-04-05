require 'rails_helper'
require 'faker'
RSpec.describe Api::V1::Authorizations::RegisterController, type: :request do

  before do 
    @organization = FactoryBot.create(:organization)
    @role = FactoryBot.create(:role)
    @user = FactoryBot.create(:user, role_id: @role.id,organization_id: @organization.id)
    @token = JsonWebToken.encode(organization_id: @organization.id)
  end

  
  describe "POST /api/v1/register" do 
    context "When organization creating a user" do 
      let(:params) do 
        {
          user: {
            email: Faker::Internet.email,
            password: "Employee@123",
            first_name: "test_first_name",
            middle_name: "test_last_name",
            last_name: "test_last_name",
            phone_number: "123456789",
            gender: "male",
            role_id: @role.id,
            shift_start: "10:00:00",
            shift_end: "19:00:00",
            buffer_time: "00:15:00",
            shift_mode: "fixed" 
          }
        }
      end
        let(:invalid_params) do 
        {
          user: {
            email: Faker::Internet.email,
            first_name: "test_first_name",
            middle_name: "test_last_name",
            last_name: "test_last_name",
            phone_number: "123456789",
            gender: "male",
            role_id: @role.id,
            shift_start: "10:00:00",
            shift_end: "19:00:00",
            buffer_time: "00:15:00",
            shift_mode: "fixed" 
          }
        }
      end
      it "create user with valid data" do
        post "/api/v1/register", headers: {token: @token},params: params
        data = JSON.parse(response.body)
        expect(data["message"]).to eq("User created successfully")
        expect(data["user"]["role"]["name"]).to eq(@role.name)
        expect(response).to have_http_status(201)
      end
      it "create give error with in_valid data" do
        post "/api/v1/register", headers: {token: @token},params: invalid_params
        data = JSON.parse(response.body)
        expect(data["message"]).to eq("Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character")
        expect(response).to have_http_status(422)
      end
    end
  end
  describe "POST /api/v1/register" do 
    @organization = FactoryBot.create(:organization)
    @role = FactoryBot.create(:role)
    @permission = Permission.find_or_create_by(name: 'create_users')
    @user = FactoryBot.create(:user, role_id: @role.id,organization_id: @organization.id)
    @token = JsonWebToken.encode(user_id: @user.id)
    @role.permissions << @permission
    context "When user with permission creating a user" do    
     let(:params) do 
      {
        user: {
          email: Faker::Internet.email,
          password: "Employee@123",
          first_name: "test_first_name",
          middle_name: "test_last_name",
          last_name: "test_last_name",
          phone_number: "123456789",
          gender: "male",
          role_id: @role.id,
          shift_start: "10:00:00",
          shift_end: "19:00:00",
          buffer_time: "00:15:00",
          shift_mode: "fixed" 
      }
     }
     end
     let(:invalid_params) do 
      {
        user: {
          email: @organization.email,
          password: "Employee@123",
          first_name: "test_first_name",
          middle_name: "test_last_name",
          last_name: "test_last_name",
          phone_number: "123456789",
          gender: "male",
          role_id: @role.id,
          shift_start: "10:00:00",
          shift_end: "",
          buffer_time: "",
          shift_mode: "fixed" 
        }
      }
     end
     let(:invalid_password_params) do 
      {
        user: {
          email: Faker::Internet.email,
          password: "Employe",
          first_name: "test_first_name",
          middle_name: "test_last_name",
          last_name: "test_last_name",
          phone_number: "123456789",
          gender: "male",
          role_id: @role.id,
          shift_start: "10:00:00",
          shift_end: "19:00:00",
          buffer_time: "00:15:00",
          shift_mode: "fixed" 
        }
      }
     end
     let(:invalid_user_params) do 
      {
        user: {
          password: "Employee@123",
          first_name: "test_first_name",
          middle_name: "test_last_name",
          last_name: "test_last_name",
          phone_number: "123456789",
          gender: "male",
          role_id: @role.id,
          shift_start: "10:00:00",
          shift_end: "19:00:00",
          buffer_time: "00:15:00",
          shift_mode: "fixed"  
        }
      }
     end
      it "creates a user" do
        post "/api/v1/register", headers: {token: @token},params: params
        data = JSON.parse(response.body)
        expect(data["message"]).to eq("User created successfully")
        expect( data["user"]['first_name']).to eq("test_first_name")
        expect(response).to have_http_status(201)
      end
      it "gives error when user without permission create a user" do
       user = FactoryBot.create(:user, role_id: @role.id)
       @token = JsonWebToken.encode(user_id: user.id)
       post "/api/v1/register", headers: {token: @token},params: params
       data = JSON.parse(response.body)
       expect(data["message"]).to eq("You are not authorized to create Users")
       expect(response).to have_http_status(422)
      end
      it "gives error when organization email and user create email is same" do 
        post "/api/v1/register", headers: {token: @token},params: invalid_params
        data = JSON.parse(response.body)
        expect(data["message"]).to eq("Email cannot be same as organization mail")
        expect(response).to have_http_status(422)
      end
      it "gives error when password not in valid format" do 
        post "/api/v1/register", headers: {token: @token},params: invalid_password_params
        data = JSON.parse(response.body)
        expect(data["message"]).to eq("Password should be a minimum of 8 characters long, contain both uppercase and lowercase characters, atleast one digit, and one special character")
        expect(response).to have_http_status(422)
      end
      it "gives validation error" do 
        post "/api/v1/register", headers: {token: @token},params: invalid_user_params
        data = JSON.parse(response.body)
        expect(data["error"]).to eq(["Email can't be blank", "Email is invalid"])
        expect(response).to have_http_status(422)
      end
    end
  end
end
