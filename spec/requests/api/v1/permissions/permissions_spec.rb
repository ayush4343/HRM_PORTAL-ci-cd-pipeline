require 'rails_helper'
require 'faker'
RSpec.describe Api::V1::Permissions::PermissionsController, type: :request do
  before do 
    @user = FactoryBot.create(:user)
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  describe 'GET /api/v1/permissions' do
    it 'returns a list of permissions' do
      FactoryBot.create_list(:permission, 3)

      get '/api/v1/permissions/permissions', headers: { token: @token }
      data = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(data.size).to eq(3)
    end
  end

  describe 'POST /api/v1/permissions' do
    it 'creates a new permission' do
      permission_params = { name: 'Permission1' }

      post '/api/v1/permissions/permissions', headers: { token: @token }, params: { permission: permission_params }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(data["messages"]).to eq("permission created sucessfully")
      expect(data["permission"]["name"]).to eq('Permission1')
    end

    it 'returns unprocessable_entity for invalid permission creation' do
      post '/api/v1/permissions/permissions', headers: { token: @token }, params: { permission: { name: nil } }
      data = JSON.parse(response.body)
      expect(data["response_message"]).to eq("Name can't be blank")
      expect(data["response_code"]).to eq(400)
    end
  end
end
