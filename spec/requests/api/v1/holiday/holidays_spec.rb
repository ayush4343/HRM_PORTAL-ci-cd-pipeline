require 'rails_helper'

RSpec.describe Api::V1::Holiday::HolidaysController, type: :request do

  let(:organization) { FactoryBot.create(:organization) }
  let(:token) {JsonWebToken.encode(organization_id: organization.id) }
  let(:role) { FactoryBot.create(:role) }


  describe "POST /api/v1/holiday/public_holidays" do 
    context "when login as a user" do 
      let(:valid_params) do 
        {
          public_holiday:{
          name: "Holi",
          start_date: "25/03/2024",
          end_date: "25/03/2024"
        }
      }
      end

    
      it 'created public holiday count 1' do
        expect {
           post '/api/v1/holiday/public_holidays',headers: {token: token}, params: valid_params}.to change(PublicHoliday, :count).by(1)
      end

      it 'returns HTTP status 201 Created' do
        post '/api/v1/holiday/public_holidays',headers: {token: token}, params: valid_params
        expect(response).to have_http_status(:created)
      end
      
      let(:invalid_params) do 
        {
          public_holiday: {
            start_date: "2024-03-25",
            end_date: "2024-03-25"
          }
        }
      end

      it 'returns HTTP status 401 Created' do
        post '/api/v1/holiday/public_holidays',headers: {token: @token}, params: invalid_params
        expect(response).to have_http_status("401")
      end

      it 'count 0 of public holiday' do
        expect {
          post '/api/v1/holiday/public_holidays',headers: {token: @token}, params: invalid_params}.to change(PublicHoliday, :count).by(0)
      end
      
    end

  end
end
