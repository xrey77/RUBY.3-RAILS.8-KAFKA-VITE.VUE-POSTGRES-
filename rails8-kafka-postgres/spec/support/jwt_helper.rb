# spec/support/jwt_helper.rb
module JwtHelper
    def jwt_token_for(user)
      payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
      secret = Rails.application.credentials.secret_key_base
      JWT.encode(payload, secret, 'HS256')
    end
  
    def authenticated_header(user)
      token = jwt_token_for(user)
      { 'Authorization' => "Bearer #{token}" }
    end
  end
  