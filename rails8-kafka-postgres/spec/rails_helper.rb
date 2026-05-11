#spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require_relative 'support/jwt_helper'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
  config.before(:each, type: :request) do
    Rails.application.reload_routes_unless_loaded
  end

  config.include JwtHelper, type: :request
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]
  config.use_transactional_fixtures = true

  config.before(:suite) do
    Rails.application.reload_routes_unless_loaded
  end

  config.filter_rails_from_backtrace!
end
