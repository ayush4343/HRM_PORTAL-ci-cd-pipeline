require 'rails_helper'
require 'faker'
RSpec.describe Api::V1::Notifications::NotificationsController, type: :request do

  before do 
    @organization = FactoryBot.create(:organization)
    @user = FactoryBot.create(:user, role: 'super_admin', organization_id: @organization.id)
    @token = JsonWebToken.encode(user_id: @user.id)
    @notification = FactoryBot.create(:notification, recipient_id: @user.id)
  end

   describe "GET /api/v1/notifications/notifications" do
    context 'with valid parameters' do
      let(:valid_params) do 
        {
          page: 2,
          recipient_id: @user.id
        }
      end

      it "returns notification messages with pagination" do
        get "/api/v1/notifications/notifications", headers: { token: @token }, params: valid_params
        json_data = JSON.parse(response.body)
        expect(response).to have_http_status(200)
      end

       let(:valid_params1) do 
        {
          recipient_id: @user.id
        }
      end

      it "returns notification messages with pagination" do
        get "/api/v1/notifications/notifications", headers: { token: @token }, params: valid_params1
        json_data = JSON.parse(response.body)
        expect(response).to have_http_status(200)
      end
    end
  end


  describe "put /api/v1/notifications/notifications/read_all_notificatons" do
    context 'with valid parameters' do
      let(:valid_params1) do 
        {
          data: {
            ids: @notification.id
          } 
        }
      end

      it "read_all_notificatons" do
        put "/api/v1/notifications/notifications/read_all_notificatons", headers: { token: @token }, params: valid_params1
        json_data = JSON.parse(response.body)
        expect(response).to have_http_status(200)
      end

      let(:valid_params) do 
        {
          data: {
            ids: nil
          } 
        }
      end

      it "read_all_notificatons else condition" do
        put "/api/v1/notifications/notifications/read_all_notificatons", headers: { token: @token }, params: valid_params
        json_data = JSON.parse(response.body)
        expect(json_data["message"]).to include("Something went wrong, please provide ids..!")
      end
    end
  end


  describe "GET /api/v1/notifications/notifications/:id" do
    context 'with valid parameters' do
      it "show method" do
        get "/api/v1/notifications/notifications/#{@notification.id}", headers: { token: @token }
        json_data = JSON.parse(response.body)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET /api/v1/notifications/notifications/:id" do
    context 'with valid parameters' do
      it "delete method" do
        delete "/api/v1/notifications/notifications/#{@notification.id}", headers: { token: @token }
        json_data = JSON.parse(response.body)
        expect(response).to have_http_status(200)
      end
    end
  end
end
