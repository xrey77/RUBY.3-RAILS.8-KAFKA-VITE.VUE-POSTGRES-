
class Api::RegisterController < ActionController::API

        def userRegistration

            @user = User.new(register_params)
            @user.role_id = 3
            if @user.save            
                render json: { 
                    message: 'You have successfully registered, please login now.'
                }, status: :created      
            else
                render json: { message: @user.errors.full_messages[0] }, status: :unprocessable_entity
            end
        end

        private

        def register_params
          params.require(:register).permit(
            :firstname, :lastname, :email_address, :mobile,
            :username, :password)
        end        


end
