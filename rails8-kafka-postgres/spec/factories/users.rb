# spec/factories/users.rb
FactoryBot.define do
    factory :user do
        username { "testuser"}
        password { "password123" }
        email_address { "test@example.com" }    
        role { "ROLE_USER"}
    end
  end
  