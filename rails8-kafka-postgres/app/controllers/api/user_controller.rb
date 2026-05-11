require 'bcrypt'
require 'fileutils'
require('base64')

class Api::UserController < ApplicationController
    
    # rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

    def getUser
        idno = params[:id]
        
        @user = User.find_by(id: idno)
        if @user.present?

            role_name = @user.role&.name 

            handle = KAFKA_PRODUCER.produce(
                topic:   "central_events",
                payload: { user_id: @user.id, action: "getuserid" }.to_json,
                key:     "user-getid"
            )
            handle.wait 


            render json: { 
                id: @user.id,
                firstname: @user.firstname,
                lastname: @user.lastname,
                email: @user.email_address,
                mobile: @user.mobile,
                roles: role_name,
                isactivated: @user.isactivated,
                isblocked: @user.isblocked,
                userpic: @user.userpic,
                message: 'User Profile Found.'
              }, status: :ok      
    
        else
            render json: { 
                message: 'User Profile ID not found.'
              }, status: :unprocessable_entity       
        end

    end

    def getAllusers
        found = false
        page = params[:page]
        perpage = 5
        offset = (page.to_i - 1) * perpage;
        totrecs = User.all.count
        tot1 = (totrecs.to_f / perpage)
        totalpage = tot1.ceil

        @users = User.limit(perpage).offset(offset)
        if @users.size > 0
            found = true
        end

        if found

            handle = KAFKA_PRODUCER.produce(
                topic:   "central_events",
                payload: { user_id: totrecs, action: "getusers" }.to_json,
                key:     "user-getusers"
            )
            handle.wait 

            render json: {
                page: page,
                totpage: totalpage,
                totalrecords: totrecs,
                users: @users,
            }, status: :ok
        else   
            render json: { 
                message: 'No record(s) found.'
                }, status: :unprocessable_entity                   
    
        end
    end
    
    def profileUpdate
        idno = params[:id]        
        json_body = request.body.read
        jdata = JSON.parse(json_body)
        @user = User.find_by(id: idno)
        if @user.present?
            @user.firstname = jdata["firstname"]
            @user.lastname = jdata["lastname"]
            @user.mobile = jdata["mobile"]
            @user.save

            handle = KAFKA_PRODUCER.produce(
                topic:   "central_events",
                payload: { user_id: @user.id, action: "profileupdate" }.to_json,
                key:     "user-profileupdate"
            )
            handle.wait 

            render json: {
                message: 'Your profile has been updated successfully.'
                }, status: :ok                   
        else
            render json: { message: 'User ID does not exists.' }, status: :not_found
        end
    end

    def changePassword
        idno = params[:id]
        json_body = request.body.read
        jdata = JSON.parse(json_body)
        pwd = jdata["password"]

        @user = User.find_by(id: idno)
        if @user.present?
            hash = BCrypt::Password.create(pwd)            
            @user.password_digest = hash
            @user.save

            handle = KAFKA_PRODUCER.produce(
                topic:   "central_events",
                payload: { user_id: @user.id, action: "changepassword" }.to_json,
                key:     "user-changepassword"
            )
            handle.wait 


            render json: { 
                message: 'Your password has been changed successfully.'
                }, status: :ok                   
    
        else
            render json: { 
                message: 'User ID does not exists.'
                }, status: :not_found                   
    
        end
    end 

    def changeProfilepic
        @idno = params[:id]
        uploaded_file = params[:userpic]

        if uploaded_file.present?
            @filename = uploaded_file.original_filename
            @ext = File.extname(@filename)
            @newfilename = "00" + @idno + @ext
    
            destination_path = Rails.root.join('public', 'users', @newfilename)

            @user = User.find_by(id: @idno.to_i)
            if @user.present?

                # delete old picture
                @oldFileExt = File.extname(URI.parse(@user.userpic).path)
                @oldPic = "00" + @idno + @oldFileExt
                publicPath = Rails.root.join('public', 'users', @oldPic)
                if File.exist?(publicPath)
                    FileUtils.rm(publicPath)
                end

                # save new picture
                @urlpic = @newfilename
                @user.userpic = @urlpic
                @user.save
            end

            # Write the file to the public/users folder
            File.open(destination_path, 'wb') do |file|
              file.write(uploaded_file.read)
            end

            handle = KAFKA_PRODUCER.produce(
                topic:   "central_events",
                payload: { user_id: @user.id, action: "uploadpicture" }.to_json,
                key:     "user-uploadpicture"
            )
            handle.wait 

            render json: { 
                message: 'Your Profile Picture has been changed successfully.'
                }, status: :ok                   
                            
        else
            render json: { 
                message: 'No image uploaded, please select image to upload.'
                }, status: :unprocessable_entity                   
    
        end
    end

    private

    def upload_params
        params.permit(:userpic)
      end

    def authenticate_user
      header = request.headers['Authorization']
    #   token = header&.split(' ')&.last 
      token = header.is_a?(String) ? header.split(' ').last : nil

    #   decoded_payload = JsonWebToken.decode(token)
      decoded_payload = JsonWebToken.decode(token) if token      
      if decoded_payload
        idno = decoded_payload['data']
        @current_user = User.find_by(id: idno.to_i)
      end
  
      render json: { message: 'Unauthorized Access' }, status: :unauthorized unless @current_user
    end

    # private

    # def user_not_found
    #   render json: { message: 'User ID does not exists.' }, status: :not_found
    # end    

end
