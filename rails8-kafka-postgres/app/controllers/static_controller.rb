class StaticController < ApplicationController
  def index
    # Render the static file directly
    render file: Rails.public_path.join('index.html'), layout: false
  end
end
