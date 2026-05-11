require 'rails_helper'
  
RSpec.describe "Api::Users", type: :request do

  before(:each) do
    Role.find_or_create_by(id: 3, name: 'ROLE_USER') 
  end
   
  def json_response
    JSON.parse(response.body)
  end  

  let!(:user) { create(:user, id: 123, firstname: "John", lastname: "Doe", email_address: "john@example.com", isactivated: true) }

  let(:headers) do
    auth_token = authenticated_header(user)
    {
      "HTTP_AUTHORIZATION" => auth_token['Authorization'],
      "Accept"             => "application/json"
    }
  end  

  let(:invalid_id) { 999 }

  let(:mock_producer) { instance_double("Kafka::Producer") }
  let(:mock_handle) { instance_double("Kafka::Producer::Handle") }

  before do
    stub_const("KAFKA_PRODUCER", mock_producer)
    allow(mock_producer).to receive(:produce).and_return(mock_handle)
    allow(mock_handle).to receive(:wait)
  end

#   describe "GET /api/getuserid/:id (getUser)" do
#     context "when user exists" do
#       it "returns user details and status ok" do

#         get "/api/getuserid/#{user.id}", headers: headers

#         expect(response).to have_http_status(:ok)
        
#         json_response = JSON.parse(response.body)
#         expect(json_response["firstname"]).to eq("John")
#         expect(json_response["message"]).to eq('User Profile Found.')
        
        # expect(mock_producer).to have_received(:produce).with(
        #   topic: "central_events",
        #   payload: { user_id: user.id, action: "getuserid" }.to_json,
        #   key: "user-getid"
        # )
#       end
#     end

#     context "when user does not exist" do
#       it "returns error message and unprocessable_entity" do
#         get "/api/getuserid/#{invalid_id}"
        
#         expect(response).to have_http_status(:unprocessable_entity)
#         json_response = JSON.parse(response.body)
#         expect(json_response["message"]).to eq('User Profile ID not found.')
#       end
#     end
#   end






#   describe "GET /api/getallusers/:page (getAllusers)" do
#     context "when user exists" do    
#         let!(:users) { create_list(:user, 6) }
#         let(:page) { 1 } 
#         it "returns paginated users and triggers kafka" do

#         get "/api/getallusers/#{page}", headers: headers, params: { page: 1 }
        
#         expect(response).to have_http_status(:ok)
        
#         json_response = JSON.parse(response.body)
#         expect(json_response["users"].size).to eq(5)
#         expect(json_response["totpage"]).to be > 0
        
#         expect(mock_producer).to have_received(:produce)
#         end
#     end
#   end





describe "PATCH /api/updateProfile/:id" do
    let!(:user_to_update) { create(:user, firstname: "Oldman", lastname: "OldName", mobile: "12323423") }

    let(:valid_params) do
      {
        firstname: "Newname",
        lastname: "Person",
        mobile: "999"
      }
    end

    context "when user exists" do
        it "updates the user and produces a kafka message" do

            patch "/api/updateprofile/#{user.id}", params: valid_params, headers: headers, as: :json
            expect {
                patch "/api/updateprofile/#{user_to_update.id}", params: valid_params, headers: headers, as: :json
              }.to change { user_to_update.reload.firstname }.from("Oldman").to("Newname")            

            expect(mock_producer).to have_received(:produce).with(
                topic: "central_events",
                payload: { user_id: user.id, action: "profileupdate" }.to_json,
                key: "user-profileupdate"
              )
      
            expect(JSON.parse(response.body)["message"]).to eq('Your profile has been updated successfully.')

        end
    end

    context "when user does not exist" do
        it "returns error message and not found" do    
            patch "/api/updateProfile/#{invalid_id}", headers: headers
            expect(response).to have_http_status(:not_found)
        end
    end    
  end




  describe "PATCH /api/changepassword/:id" do
    let!(:userpassword_to_update) { create(:user, password: "oldpassword") }

    let(:valid_params) do
      {
        password: "newpassword",
      }
    end

    context "when user exists" do
        it "updates the user password and produces a kafka message" do

            expect {
                patch "/api/changepassword/#{user.id}", params: valid_params, headers: headers, as: :json
              }.to change { user.reload.authenticate("newpassword") }.from(false).to(user)
              
            expect(response).to have_http_status(:success)

            expect(mock_producer).to have_received(:produce).with(
                topic: "central_events",
                payload: { user_id: user.id, action: "changepassword" }.to_json,
                key: "user-changepassword"
              )
      
            expect(JSON.parse(response.body)["message"]).to eq('Your password has been changed successfully.')

        end
    end

    context "when user does not exist" do
        it "returns error message and not found" do    
            patch "/api/changePassword/#{invalid_id}"  
            expect(response).to have_http_status(:not_found)
        end
    end    
  end



end
