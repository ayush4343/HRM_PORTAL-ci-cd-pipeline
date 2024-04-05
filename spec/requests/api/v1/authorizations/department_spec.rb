require 'rails_helper'
require 'faker'
RSpec.describe Api::V1::Authorizations::DepartmentController, type: :request do

    let(:organization) { FactoryBot.create(:organization) }
    let(:token) {JsonWebToken.encode(organization_id: organization.id) }
    let(:role) { FactoryBot.create(:role) }

  describe "create department for organization" do
    context "Create Action" do 
      concerns = Faker::Lorem.words(number: 3)
      name =  Faker::Name.unique.name
      let(:valid_params) do
          {
              "department_name": name,
             "permissions_to":  [role.id],
              "concerns": concerns
          }
      end
  
      it "create department for an organization" do 
         post '/api/v1/create_department', headers: {token: token}, params: valid_params 
         data = JSON.parse(response.body)
         expect(data["department"]["name"]).to eq(name)
         expect(response).to have_http_status(201) 
      end
       let(:invalid_params) do
          {
              "department_name": name,
             "permissions_to":  [Faker::Number.decimal_part(digits: 2)],
              "concerns": concerns
          }
      end
      it "raise a role not valid message" do 
        post '/api/v1/create_department', headers: {token: token}, params: invalid_params
        data = JSON.parse(response.body)
        expect(data["message"]).to eq("Role is not valid")
      end

      it "raise a valid data error" do 
        post '/api/v1/create_department', headers: {token: token}
        data = JSON.parse(response.body)
        expect(data["message"]).to eq("Please provide valid data")
      end
    end

    context "/index" do 
    
      it "#index" do 
        @dept = FactoryBot.create(:department, organization_id: organization.id)
        FactoryBot.create(:department_role, department_id: @dept.id, role_id: role.id)
        concern = FactoryBot.create(:concern, department_id: @dept.id)
        get '/api/v1/get_departments', headers: {token: token}
        data = JSON.parse(response.body)
        expect(data[0]["name"]).to eq(@dept.name)
        expect(data[0]["concerns"][0]["name"]).to eq(concern.name)
      end

    end

    context "show department" do 
      it "#show" do 
        @dept = FactoryBot.create(:department, organization_id: organization.id)
        get '/api/v1/show_department', params: { id: @dept.id }
        data = JSON.parse(response.body)
        expect(data["name"]).to eq(@dept.name)
      end
    end
     context "show concern" do 
      it "#show" do 
        department = FactoryBot.create(:department, organization_id: organization.id)
        @concern  = FactoryBot.create(:concern, department_id: department.id)
        get '/api/v1/show_concern', params: { id: department.id }
        data = JSON.parse(response.body)
        expect(data[0]["name"]).to eq(@concern.name)
        expect(response).to have_http_status(200)
      end
      it "gives error" do 
         get '/api/v1/show_concern'
        data = JSON.parse(response.body)
        expect(data["message"]).to eq("Id not present")
        expect(response).to have_http_status(422)
      end 
    end
    
    
  end

end
