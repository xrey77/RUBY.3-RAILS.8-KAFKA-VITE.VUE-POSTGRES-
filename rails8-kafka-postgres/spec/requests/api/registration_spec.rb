require 'rails_helper'

RSpec.describe "Api::RegisterControllers", type: :request do

before(:each) do
    Role.find_or_create_by(id: 3, name: 'ROLE_USER') 
end

  let(:valid_params) do
    {
      register: {
        firstname: "Reynald",
        lastname: "Gragasin",
        email_address: "reynald@yahoo.com",
        mobile: "1234567890",
        username: "Reynald",
        password: "rey"
      }
    }
  end

  describe "POST /api/signup" do
    context "with valid parameters" do
      it "creates a new user, sets role_id to 3, and produces a Kafka message" do

        delivery_handle = instance_double(Rdkafka::Producer::DeliveryHandle)
        allow(delivery_handle).to receive(:wait)      
        allow(KAFKA_PRODUCER).to receive(:produce).and_return(delivery_handle)

        expect {
          post "/api/signup", params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["message"]).to eq('You have successfully registered, please login now.')
        puts response.body
        
        user = User.last
        expect(user.role_id).to eq(3)

        expect(KAFKA_PRODUCER).to have_received(:produce).with(
          topic: "central_events",
          payload: { user_id: user.id, action: "register" }.to_json,
          key: "user-registration"
        )

      end
    end

    context "with invalid parameters" do

    before do
        allow(KAFKA_PRODUCER).to receive(:produce)
    end

      let(:invalid_params) { { register: { username: "", email_address: "", firstname: "", lastname: "" } } }

      it "does not create a user and returns unprocessable_entity" do
        expect {
          post "/api/signup", params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("message")
        
        expect(KAFKA_PRODUCER).not_to have_received(:produce)
      end
    end
  end
end
