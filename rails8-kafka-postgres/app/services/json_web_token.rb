class JsonWebToken
    # SECRET_KEY = Rails.application.credentials.secret_key_base # Use a strong, securely stored key
    SECRET_KEY = Rails.application.credentials.secret_key_base || 
    File.read(Rails.root.join('tmp/local_secret.txt')).strip

    def self.encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY, 'HS256')      
    end
  
    def self.decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]      
      HashWithIndifferentAccess.new decoded
    rescue JWT::DecodeError => e
      nil      
    end
    
    # def self.encode(payload, exp = 8.hours.from_now)
    #   payload[:exp] = exp.to_i
    #   JWT.encode(payload, SECRET_KEY, 'HS256') # Specify the algorithm
    # end
  
    # def self.decode(token)
    #   decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    #   decoded[0] # Returns the payload
    # rescue JWT::DecodeError
    #   nil # Return nil if decoding/verification fails
    # end
  end
  