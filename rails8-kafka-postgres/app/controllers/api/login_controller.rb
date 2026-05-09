require 'jwt'

class Api::LoginController < ActionController::API

        def userLogin

          @user = User.find_by(username: login_params[:username])
          if @user.present?

            if @user.present? && @user.authenticate(login_params[:password])
              exp = 8.hours.from_now
              @user_id = @user.id
              payload = { data: @user_id, exp: exp.to_i }
              token = JsonWebToken.encode(payload)
              role_name = @user.role&.name 
              
                
              handle = KAFKA_PRODUCER.produce(
                topic:   "central_events",
                payload: { user_id: @user.id, action: "login" }.to_json,
                key:     "user-login"
              )
              handle.wait 

              render json: { 
                id: @user.id,
                username: @user.username,
                firstname: @user.firstname,
                lastname: @user.lastname,
                email: @user.email_address,
                mobile: @user.mobile,
                roles: role_name,
                isactivated: @user.isactivated,
                isblocked: @user.isblocked,
                userpic: @user.userpic,
                qrcodeurl: @user.qrcodeurl,
                token: token,
                message: 'Login Successfull.'
              }, status: :ok       
              return
                



            else
              render json: { 
                message: 'Invalid Password, please try again.'
              }, status: :unprocessable_entity       
  
            end

          else            
            render json: { 
              message: 'Username not found, please register.'
            }, status: :unprocessable_entity     

          end

        end

        private

        def login_params
          params.require(:login).permit(:username, :password)
        end        
end
