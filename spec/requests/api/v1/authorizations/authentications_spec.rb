require 'rails_helper'
require 'faker'
RSpec.describe Api::V1::Authorizations::RegisterController, type: :request do

  before do 
    @organization = FactoryBot.create(:organization)
    @role = FactoryBot.create(:role)
    @user = FactoryBot.create(:user, role_id: @role.id,organization_id: @organization.id)
    @token = JsonWebToken.encode(user_id: @user.id)
  end
  describe "POST /api/v1/authentication" do 
    context "when login as a user" do 
      let(:valid_params) do 
        {data:{
        email: @user.email,
        password: @user.password
      }
      }
      end
      it "login as a user" do 
        post '/api/v1/authentication', params: valid_params
        data = JSON.parse(response.body)
        expect(data["data"]["message"]).to eq("Logged in successfully")
        expect(response).to have_http_status(200)
      end
      it "gives record not found error" do 
        post '/api/v1/authentication', params: {data:{email: "qwertyjhgf", password: @user.password}}
        data = JSON.parse(response.body)
        expect(data["error"]).to eq("Record not found")
        expect(response).to have_http_status(422)
      end
      it "when gives incorrect passeord" do 
        post '/api/v1/authentication', params: {data:{email: @user.email, password: "qwertjnhbg"}}
        data = JSON.parse(response.body)
        expect(data["error"]).to eq("enter correct password")
        expect(response).to have_http_status(401)
      end
    end
    context "when login as a organization" do 
      let(:valid_params) do 
        {data:{
          email: @organization.email,
          password: @organization.password
        }
        }
      end
      it "login as a organization" do 
        post '/api/v1/authentication', params: valid_params
        data = JSON.parse(response.body)
        expect(data["data"]["message"]).to eq("Logged in successfully")
        expect(data["data"]["data"]["company_name"]).to eq(@organization.company_name)
        expect(response).to have_http_status(200)
      end
      it "gives record not found error" do 
        post '/api/v1/authentication', params: {data:{email: "qwertyjhgf", password: @organization.password}}
        data = JSON.parse(response.body)
        expect(data["error"]).to eq("Record not found")
        expect(response).to have_http_status(422)
      end
      it "when gives incorrect passeord" do 
        post '/api/v1/authentication', params: {data:{email: @user.email, password: "qwertjnhbg"}}
        data = JSON.parse(response.body)
        expect(data["error"]).to eq("enter correct password")
        expect(response).to have_http_status(401)
      end
  end
  end
end
