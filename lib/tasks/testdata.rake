#encoding: utf-8
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    #Create test store
    store = MerchantStore.create(description: 'Michels karameller er bare dejlige', street: 'Klostervangen', house_number: '34', 
        postal_code: '3360', city: 'Liseleje', denmark: 'Denmark', owner: 'Michel Hansen', store_name: 'Michels karameller', sms_keyword: 'CN2')
    store.
    #Create backend admin user
    merchant_user = MerchantUser.create(name: "Michel Kenneth Hansen",
                 role: "Sales clerk")
    user = User.create(
                 email: "michelhansen75@hotmail.com",
                 password: "noniryder",
                 password_confirmation: "noniryder")
    user.sub = merchant_user
    #Create test-store plus member til Michel
    
    store.merchants.create!(name: "Michel Kenneth Hansen",
                 email: "scoop751@hotmail.com",
                 password: "noniryder",
                 password_confirmation: "noniryder")
    #store.create_subscription!(name: 'Standard', description: 'Nice', monthly_price: '199,95', start_date: Time.now, active: true)
    #store.create_welcome_offer!(description: 'Super', active: true)

    #Create test members for Michel
    5.times do |n| 
        name = Faker::Name.name
        email = "example-tr-#{n}@disruptx.dk"
        phone = Faker::PhoneNumber.phone_number
        member = Member.create!(  name: name,
                                  email: email,
                                  phone: phone)
        store.subscribers.create!(member_id: member.id, start: Time.now)
        store.create_subscription!(name: 'Standard', description: 'Nice', monthly_price: '199,95', start_date: Time.now, active: true)
        store.create_welcome_offer!(description: 'Super', active: true)              
    end

    10.times do |s|      
      description = 'Lorem Ipsum Lorem Ipsum Lorem Ipsum'
      street = 'Nørregade'
      house_number = '29'
      postal_code = '3300'
      city = 'Frederiksværk'
      owner = 'Hans Nielsen' 
      store_name = "Cafe & Steakhouse #{s+1}"
      keyword = "cn#{s+1}"  
      store = MerchantStore.create(description: description, street: street, house_number: house_number, 
        postal_code: postal_code, city: city, owner: owner, store_name: store_name, keyword: keyword)
      #Create merchant user
      1.times do |user|
        store.merchants.create!(name: "Example User",
                 email: "example-#{s}-#{user}@example120.org",
                 password: "foobar",
                 password_confirmation: "foobar")
        store.create_subscription!(name: 'Standard', description: 'Nice', monthly_price: '199,95', start_date: Time.now, active: true)
        store.create_welcome_offer!(description: 'Super', active: true)
      end 
      #Create subscriber for each merchant     
      5.times do |n| 
        name = Faker::Name.name
        email = "example-#{s}-#{n}@disruptx.dk"
        phone = Faker::PhoneNumber.phone_number
        member = Member.create!(  name: name,
                                  email: email,
                                  phone: phone)
        store.subscribers.create!(member_id: member.id, start: Time.now)              
      end
    end
=begin
    Merchant.create!(name: "Example User",
                 email: "example@railstutorial.org",
                 password: "foobar",
                 password_confirmation: "foobar")
    35.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      Merchant.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
=end

    #Create inactive offers
    15.times do |n|
        title = "Tilbud på kaffe"
        description = "Lorem ipsum Lorem ipsum Lorem ipsum"
        valid_from = (Time.now - 50.days)
        valid_to = (Time.now - 10.days)
        offer = Offer.create(title: title, description: description, valid_from: valid_from, valid_to: valid_to)
        offer.promotion_plans.build(comments: "Lorem ipsum", delivery: (Time.now - 40.days), instant: false, notification_type: "SMS") 
    end 
    #Create active offers
    15.times do |n|
        title = "Tilbud på chocolade"
        description = "Lorem ipsum Lorem ipsum Lorem ipsum"
        valid_from = (Time.now - 5.days)
        valid_to = (Time.now + 20.days)
        offer = Offer.create(title: title, description: description, valid_from: valid_from, valid_to: valid_to)
        offer.promotion_plans.build(comments: "Lorem ipsum", delivery: (Time.now - 5.days), instant: false, notification_type: "SMS") 
    end

    #Create completed promotion plans
    15.times do |n|
        title = "Påmindelse til kaffetilbud"
        comments = "Lorem ipsum Lorem ipsum Lorem ipsum"
        delivery = (Time.now - 10.days)
        status = 'Completed'
        PromotionPlan.create(title: title, comments: comments, delivery: delivery, status: status, instant: false, notification_type: "SMS")        
    end 
    #Create scheduled promotion plans
    15.times do |n|
        title = "Påmindelse til kaffetilbud"
        comments = "Lorem ipsum Lorem ipsum Lorem ipsum"
        delivery = (Time.now + 5.days)
        status = 'Active'
        PromotionPlan.create(title: title, comments: comments, delivery: delivery, status: status, instant: false, notification_type: "SMS")    
    end
    
  end
end