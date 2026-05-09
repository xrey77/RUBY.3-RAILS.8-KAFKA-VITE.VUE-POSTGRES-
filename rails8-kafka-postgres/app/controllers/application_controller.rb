class ApplicationController < ActionController::API
    # include Pagy::Method
    # extend Pagy::Search
    include Authenticatable
    
end
