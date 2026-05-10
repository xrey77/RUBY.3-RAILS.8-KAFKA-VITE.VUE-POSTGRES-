require "rqrcode"
require('base64')
require 'chunky_png'

class Api::MfaController < ActionController::API

    def activateMfa
        idno = params[:id]
        json_body = request.body.read
        jdata = JSON.parse(json_body)
        if (jdata["TwoFactorEnabled"] == true)

            @user = User.find_by(id: idno.to_i)
            if @user.present?
                @secretkey = ROTP::Base32.random
                totp = ROTP::TOTP.new(@secretkey, issuer: "SUPERCAR INC.")
                uri = totp.provisioning_uri(@user.email_address)

                qrcode = RQRCode::QRCode.new(uri)

                png = qrcode.as_png(
                  bit_depth: 1,
                  border_modules: 4,
                  color_mode: ChunkyPNG::COLOR_GRAYSCALE,
                  color: 'black',
                  file: nil,
                  fill: 'white',
                  module_size: 5,
                  resize_exactly_to: false,
                  resize_gte_to: false,
                  size: 200
                )
            
                # @base64Qrcode = 'data:image/png;base64,' + Base64.encode64(png.to_s)
                @base64Qrcode = "data:image/png;base64,#{Base64.strict_encode64(png.to_s)}"
                @user.secret = @secretkey.to_s
                @user.qrcodeurl = @base64Qrcode.to_s
                @user.save

                handle = KAFKA_PRODUCER.produce(
                    topic:   "central_events",
                    payload: { user_id: @user.id, action: "activatemfa" }.to_json,
                    key:     "user-activatemfa"
                )
                handle.wait 
    
                render json: { 
                    qrcodeurl: @base64Qrcode,
                    message: 'Multi-Factor Authenticator has been enabled.'
                }, status: :ok         
            end  
        else
            @user = User.find_by(id: idno.to_i)
            if @user.present?
                @user.secret = nil
                @user.qrcodeurl = nil
                @user.save
            end
            render json: { 
                message: 'Multi-Factor Authenticator has been disabled.'
            }, status: :ok       
        end
    end


    def verifyOtpcode
        idno = params[:id]
        json_body = request.body.read
        jdata = JSON.parse(json_body)
        otp = jdata["otp"]
        
        @user = User.find_by(id: idno.to_i)
        if @user.present?
            @username = @user.username
            totp = ROTP::TOTP.new(@user.secret, issuer: "SUPERCAR INC.")
            if totp.verify(otp, drift_behind: 15)

                handle = KAFKA_PRODUCER.produce(
                    topic:   "central_events",
                    payload: { user_id: @user.id, action: "verifyotp" }.to_json,
                    key:     "user-verifyotp"
                )
                handle.wait 
    
                render json: { 
                    username: @username,
                    message: 'OTP code has been verified successfully.'
                }, status: :ok       
            else
                render json: { 
                    message: 'Invalid OTP code, please try again.'
                }, status: :unprocessable_entity       

            end
        end
    end

end
