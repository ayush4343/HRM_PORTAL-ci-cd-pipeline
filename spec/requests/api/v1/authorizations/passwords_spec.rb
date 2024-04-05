require 'rails_helper'
require 'faker'
RSpec.describe Api::V1::Authorizations::PasswordsController, type: :request do

  before do 
    @organization = FactoryBot.create(:organization)
    @user = FactoryBot.create(:user, role: 'super_admin', organization_id: @organization.id)
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  describe "POST /api/v1/register" do
    context 'with valid parameters' do
      let(:valid_params1) do 
        {
          password: "test123455555"
        }
      end

      it "changes the user's password successfully"  do
        post "/api/v1/change_password", headers: {token: @token}, params: valid_params1
        json_data = JSON.parse(response.body)
        expect(json_data["response_message"]).to include("wrong_password")
        expect(json_data["response_code"]).to eq(400)
      end
	end

	context 'with invalid parameters' do
      let(:invalid_params) do 
        {
          new_password: "Task1233"
        }
      end

      it "returns error due to invalid password" do
        post "/api/v1/change_password", headers: { token: @token }, params: invalid_params
        json_data = JSON.parse(response.body)
        expect(json_data["response_message"]).to include("password_change_success")
        expect(json_data["response_code"]).to eq(200)
      end
    end

    context 'with invalid parameters with 400 condition' do
      let(:invalid_params) do 
        {
          new_password: nil
        }
      end

      it "returns error due to invalid password" do
        post "/api/v1/change_password", headers: { token: @token }, params: invalid_params
        json_data = JSON.parse(response.body)
        expect(json_data["response_code"]).to eq(400)
      end
    end
   end
end
