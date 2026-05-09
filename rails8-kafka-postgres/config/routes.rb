Rails.application.routes.draw do
  get "static/index"
  
  # get "up" => "rails/health#show", as: :rails_health_check
  namespace :api do

    post "/signup", to: "register#userRegistration"
    post "/signin", to: "login#userLogin"

    get "/getuserid/:id", to: "user#getUser"
    get "/getallusers/:page", to: "user#getAllusers"
    patch "/updateprofile/:id", to: "user#updateProfile"
    patch "/changepassword/:id", to: "user#changePassword"
    patch "/uploadpicture/:id", to: "user#changeProfilepic"

    patch "/mfa/activate/:id", to: "mfa#activateMfa"
    patch "/mfa/verifytotp/:id", to: "mfa#verifyOtpcode"
    
    get "/products/list/:page", to: "product#productsList"
    get "/products/search/:page/:keyword", to: "product#productsSearch"
    get "/salesdata", to: "product#getSales"

    # Defines the root path route ("/")
    root "static#index"

  end

end
