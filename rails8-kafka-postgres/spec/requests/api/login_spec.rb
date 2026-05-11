require 'rails_helper'

RSpec.describe "Api::Login", type: :request do
  
  describe "POST /api/signin" do  
    let(:valid_credentials) { { username: "Reynald", password: "rey" } }
    let!(:user) { create(:user, password: 'rey') }
    let(:login_url) { "/api/signin" }
    let(:valid_params) { { login: { username: user.username, password: 'rey' } } }
    let(:invalid_params) { { login: { username: user.username, password: 'wrongpassword' } } }
    let!(:role) { Role.create(name: "ROLE_USER") } 
    let!(:user) { create(:user, password: 'rey', role: role) }  

    before do
      delivery_handle = instance_double(Rdkafka::Producer::DeliveryHandle)
      allow(delivery_handle).to receive(:wait)    
      allow(KAFKA_PRODUCER).to receive(:produce).and_return(delivery_handle)
    end  
  
    describe "POST /api/signin" do
      context "with valid credentials" do
        before { post login_url, params: valid_params }

        it "returns a success status" do
          post "/api/signin", 
          params: { username: "Reynald", password: "rey" }.to_json,
          headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }          
          # puts response.body
          expect(response).to have_http_status(:ok)
        end

        it "returns a JWT token" do
          json_response = JSON.parse(response.body)
          # puts json_response
          expect(json_response['token']).to be_present
        end

        it "produces a login event to Kafka" do

          expect(KAFKA_PRODUCER).to have_received(:produce).with(
            topic: "central_events",
            payload: { user_id: user.id, action: "login" }.to_json, 
            key: "user-login"
          )
          post "/api/signin", params: valid_credentials, as: :json
          
        end
      end
  end

  context "with invalid password" do
      before { post login_url, params: invalid_params }

      it "returns unprocessable_content status" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns an error message" do
        expect(JSON.parse(response.body)['message']).to eq('Invalid Password, please try again.')
      end

      it "does not produce a Kafka event" do
        expect(KAFKA_PRODUCER).not_to have_received(:produce)
      end
    end

    context "with non-existent username" do
      before { post login_url, params: { login: { username: 'unknown', password: 'password' } } }

      it "returns unprocessable_content status" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns user not found message" do
        expect(JSON.parse(response.body)['message']).to eq('Username not found, please register.')
      end
    end
  end
end
