require 'rails_helper'

RSpec.describe "Api::Login", type: :request do
  let!(:user) { create(:user, password: 'password123') }
  let(:login_url) { "/api/login/userLogin" } # Update path based on your routes
  let(:valid_params) { { login: { username: user.username, password: 'password123' } } }
  let(:invalid_params) { { login: { username: user.username, password: 'wrongpassword' } } }

  # Mock Kafka Producer
  before do
    allow(KAFKA_PRODUCER).to receive(:produce).and_return(double('Handle', wait: true))
  end

  describe "POST /userLogin" do
    context "with valid credentials" do
      before { post login_url, params: valid_params }

      it "returns a success status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a JWT token" do
        json_response = JSON.parse(response.body)
        expect(json_response['token']).to be_present
      end

      it "produces a login event to Kafka" do
        # Verify the producer was called
        expect(KAFKA_PRODUCER).to have_received(:produce).with(
          topic: "central_events",
          payload: hash_including(user_id: user.id, action: "login").to_json,
          key: "user-login"
        )
      end
    end

    context "with invalid password" do
      before { post login_url, params: invalid_params }

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
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

      it "returns unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns user not found message" do
        expect(JSON.parse(response.body)['message']).to eq('Username not found, please register.')
      end
    end
  end
end
