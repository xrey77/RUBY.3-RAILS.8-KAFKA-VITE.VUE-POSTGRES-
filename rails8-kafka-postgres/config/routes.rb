Rails.application.routes.draw do
  get "static/index"
  
  root "static#index"
  # get "up" => "rails/health#show", as: :rails_health_check
  # namespace :api do
  namespace :api, defaults: { format: :json } do

    post "/signup", to: "register#userRegistration"
    post "/signin", to: "login#userLogin", as: :login

    get "/getuserid/:id", to: "user#getUser"
    get "/getallusers/:page", to: "user#getAllusers"
    patch "/updateprofile/:id", to: "user#profileUpdate"
    patch "/changepassword/:id", to: "user#changePassword"
    patch "/uploadpicture/:id", to: "user#changeProfilepic"

    patch "/mfa/activate/:id", to: "mfa#activateMfa"
    patch "/mfa/verifytotp/:id", to: "mfa#verifyOtpcode"
    
    get "/products/list/:page", to: "product#productsList"
    get "/products/search/:page/:keyword", to: "product#productsSearch"
    get "/salesdata", to: "product#getSales"
    get "/productsbycategory", to: "product#productCategory"
    # Defines the root path route ("/")
    root "static#index"

  end

end
