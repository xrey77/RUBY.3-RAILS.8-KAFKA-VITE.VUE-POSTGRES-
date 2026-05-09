# app/controllers/concerns/authenticatable.rb
module Authenticatable
    extend ActiveSupport::Concern
  
    included do
      before_action :authenticate_user
    end
  
    def authenticate_user
      header = request.headers['Authorization']
      token = header.split(' ').last if header.present?
      
      if token.blank?
        return render json: { message: 'Token missing' }, status: :unauthorized
      end

      begin
        decoded = JsonWebToken.decode(token)
        # Guard against nil decoded (if decode returns nil on error)
        return render json: { message: 'Invalid token' }, status: :unauthorized unless decoded
        
        @current_user = User.find(decoded[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { message: 'User not found' }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { message: 'Unauthorized' }, status: :unauthorized
      end      
    end
  
    attr_reader :current_user
  end
  