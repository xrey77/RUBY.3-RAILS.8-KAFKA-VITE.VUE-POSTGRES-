# spec/factories/users.rb
FactoryBot.define do
    factory :user do
        firstname { "Reynald" }
        lastname { "Gragasin" }
        # email_address { "rey@yahoo.com.com" }    
        sequence(:username) { |n| "user#{n}" }
        sequence(:email_address) { |n| "user#{n}@example.com" }        
        mobile { "23423423" }
        # username { "Reynald" }
        password { "rey" }
        association :role
    end

    factory :role do
        sequence(:name) { |n| "ROLE_USER_#{n}" }
    end    
  end
  