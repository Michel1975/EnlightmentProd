#encoding: utf-8
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    #Create address array

    house_numbers = Array.new
    house_numbers.push("14")
    house_numbers.push("10")
    house_numbers.push("1")
    house_numbers.push("32")
    house_numbers.push("16")

    #Setup independent lookup tables
    subscription_basic = SubscriptionType.create!(name: "Basis", monthly_price: '149.95')
    subscription_basic.features.create!(title: "Sms kampagner", description: "Gør det muligt at udføre sms kampagner for sine kunder")

    
    5.times do |s|
      if s == 1#!MerchantStore.all.any?
        store = MerchantStore.create!(description: 'Michels karameller er bare dejlige', short_description: 'Michels karameller er bare dejlige', phone: "48391754", street: 'Klostervangen', house_number: '34', 
            postal_code: '3360', city: 'Liseleje', country: 'Denmark', owner: 'Michel Hansen', store_name: 'Michels karameller', sms_keyword: "cn#{s+1}" )
    
        store.create_subscription_plan(start_date: Time.now, subscription_type_id: subscription_basic.id)

        #Create backend admin user
        user = User.create!(
                 email: "michelhansen75@hotmail.com",
                 password: 'password',
                 password_confirmation: 'password')
        merchant_user = store.merchant_users.create!(name: "Michel Kenneth Hansen",
                role: "Sales clerk", phone: '99999999')
        user.sub = merchant_user
        user.save! 
      else
        description = 'Lorem Ipsum Lorem Ipsum Lorem Ipsum'
        short_description =  'Lorem Ipsum Lorem Ipsum Lorem Ipsum'
        street = 'Nørregade'
        house_number = house_numbers[s]
        postal_code = '3300'
        city = 'Frederiksværk'
        country = 'Denmark'
        owner = Faker::Name.name
        store_name = "Cafe & Steakhouse #{s+1}"
        phone = "41415210"
        sms_keyword = "CN#{s+1}"  
        store = MerchantStore.create(description: description, short_description: short_description, phone: phone, street: street, house_number: house_number, 
          postal_code: postal_code, city: city, country:'Denmark', owner: owner, store_name: store_name, sms_keyword: sms_keyword)

        #Create average user record for merchant user
        name  = Faker::Name.name
        email = "test-#{s+1}@clubnovustest.dk"
        password  = "password"

        user = User.create!(
                 email: email,
                 password: password,
                 password_confirmation: password)

        #Create backend admin user
        merchant_user = store.merchant_users.create!(name: name, role: "Sales clerk", phone: '42415210' )
        user.sub = merchant_user
        user.save!
      end#end if-first-iteration
      
      #Create one welcome offer
      store.create_welcome_offer!(description: 'Super', active: true)

      #Create subscriber for each merchant     
      5.times do |n| 
        first_name = Faker::Name.first_name
        last_name = Faker::Name.last_name
        postal_code = "3360"
        gender = "W"
        email = "test-#{s}-#{n}@clubnovustest.dk"
        
        #Adding my phone number for my own store
        phone = ""
        begin
          phone = Random.rand(11111111..99999999).to_s
        end while Member.exists?(phone: phone)
          
        
        password  = "password"
        member_user = User.create!(
                 email: email,
                 password: password,
                 password_confirmation: password)
        member = Member.create!(  first_name: first_name,
                                  last_name: last_name,
                                  postal_code: postal_code,
                                  gender: gender,
                                  birthday: Date.today,
                                  phone: phone,
                                  origin:'store')
        member_user.sub = member
        member_user.save!
        store.subscribers.create!(start_date: Date.today, member_id: member.id)              
      end#end creation of members per merchant

      #Create inactive offers
      5.times do |n|
        title = "Tilbud på kaffe"
        description = "Lorem ipsum Lorem ipsum Lorem ipsum"
        valid_from = (Time.now - 50.days)
        valid_to = (Time.now - 10.days)
        store.offers.create!(title: title, description: description, valid_from: valid_from, valid_to: valid_to)
      end 
      #Create active offers
      5.times do |n|
        title = "Tilbud på chocolade"
        description = "Lorem ipsum Lorem ipsum Lorem ipsum"
        valid_from = (Time.now - 5.days)
        valid_to = (Time.now + 20.days)
        store.offers.create!(title: title, description: description, valid_from: valid_from, valid_to: valid_to)
      end

      #Create business hours
      7.times do |n|
        store.business_hours.create!(day: (Date.today.beginning_of_week + n).wday, open_time: Time.new(2013, 8, 29, 8, 30, 0), close_time: Time.new(2013, 8, 29, 16, 30, 0))
      end 

      #Create event history
      7.times do |n|
        store.event_histories.create!(description: Faker::Lorem.words(10), event_type: "login") 
      end 

      #Create welcome offer
      store.create_welcome_offer!(description: Faker::Lorem.words(10), active: true)
       

    end#end loop

    #Create one standalone member with unique email
      1.times do |n| 
        first_name = "Michel"
        last_name = "Hansen"
        postal_code = "3360"
        gender = "W"
        email = "scoop751@hotmail.com"
        phone = "42415210"
        password  = "password"
        
        member_user = User.create!(
                 email: email,
                 password: password,
                 password_confirmation: password)
        member = Member.create!(  first_name: first_name,
                                  last_name: last_name,
                                  postal_code: postal_code,
                                  gender: gender,
                                  birthday: Date.today,
                                  phone: phone,
                                  origin: 'store')
        member_user.sub = member
        member_user.save!
        #Associate standalone member with one store
        MerchantStore.first.subscribers.create!(start_date: Date.today, member_id: member.id)
      end #end creation of special standalone member

      #Create one standalone member with unique email
      1.times do |n| 
        name = "Niels Hansen"
        postal_code = "3360"
        gender = "W"
        email = "info@disruptx.dk"
        phone = "48391754"
        password  = "password"
        
        admin_user = User.create!(
                 email: email,
                 password: password,
                 password_confirmation: password)
        admin = BackendAdmin.create!( name: name,
                                      role: 'admin')
                                        
        admin_user.sub = admin
        admin_user.save!
      end #end creation of special admin user 

      #Initialize status-codes from CimMobil. Used in sms-handler. 
      status_codes = Hash.new
      status_codes[0] = "Besked afsendt"
      status_codes[1] = "Besked leveret"
      status_codes[14] = "Udsendelse igang"
      status_codes[129] = "Klar til udsendelse"
      status_codes[130] = "Udsendelse igang"
      #Custom
      status_codes[500] = "Udsendelse planlagt"
      #Custom
      status_codes[999] = "Beskeden kunne ikke sendes"

      status_codes.each do |key, value|
        StatusCode.create!(name: key, description: value)
      end
  end#end populate
end#end namespace