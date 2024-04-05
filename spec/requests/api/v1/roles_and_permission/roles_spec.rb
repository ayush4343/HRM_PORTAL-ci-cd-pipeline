require 'rails_helper'
require 'faker'
RSpec.describe Api::V1::RolesAndPermission::RolesController, type: :request do
  before do 
    @user = FactoryBot.create(:user)
    @token = JsonWebToken.encode(user_id: @user.id)
    @role1 = FactoryBot.create(:role)
    @role2 = FactoryBot.create(:role)
    @permission1 = FactoryBot.create(:permission)
    @permission2 = FactoryBot.create(:permission)
  end

  describe 'GET /api/v1/roles' do
    it 'returns a list of roles' do
      get '/api/v1/roles_and_permission/roles', headers: { token: @token }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(data.size).to eq(2)
    end
  end

  describe 'POST /api/v1/roles' do
    it 'creates a new role' do
      role_params = { name: 'Role1' }

      post '/api/v1/roles_and_permission/roles', headers: { token: @token }, params: { role: role_params }#, headers: auth_headers(user)
      data = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(data["messages"]).to eq("Role created sucessfully")
      expect(data["role"]["name"]).to eq('Role1')
    end

    it 'returns unprocessable_entity for invalid role creation' do
      post '/api/v1/roles_and_permission/roles', headers: { token: @token }, params: { role: { name: nil } }#, headers: auth_headers(user)
      data = JSON.parse(response.body)
      expect(data["response_message"]).to eq("Name can't be blank")
      expect(data["response_code"]).to eq(400)
    end
  end

  describe 'POST /api/v1/roles_and_permission/roles/:id/add_permissions' do

    it 'adds permissions to a role' do
      post "/api/v1/roles_and_permission/roles/#{@role1.id}/add_permissions", headers: { token: @token}, params: { permission_ids: [ @permission1.id, @permission2.id ] }
      expect(@role1.permissions.count).to eq(2)
      expect(response).to have_http_status(:ok)
      # expect(json_response['permissions'].size).to eq(2)
    end

    it 'returns unprocessable_entity if permission IDs are not provided' do
      post "/api/v1/roles_and_permission/roles/#{@role1.id}/add_permissions", headers: { token: @token}, params: {}
      data = JSON.parse(response.body)
      expect(data["error"]).to eq("Permission IDs are required")
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /api/v1/roles/:id/permissions' do

    before do
      @role1.permissions << [@permission1, @permission2]
    end

    it 'returns a list of permissions for a role' do
      get "/api/v1/roles_and_permission/roles/#{@role1.id}/permissions", headers: { token: @token}
      data = JSON.parse(response.body)
      expect(data.count).to eq(2)
      expect(data.first["name"]).to eq(@permission1.name) 
      expect(response).to have_http_status(:ok)
    end
  end

end