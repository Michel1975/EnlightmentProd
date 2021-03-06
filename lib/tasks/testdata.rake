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
    subscription_basic = SubscriptionType.create!(name: "Basis medlemsskab", monthly_price: '199.95')
    subscription_basic.features.create!(title: "Online promotion", description: "Skab større synlighed på nettet")
    subscription_basic.features.create!(title: "Sms kampagnemodul", description: "Lav fantastiske sms-kampagner og skab meromsætning")
    subscription_basic.features.create!(title: "Rapport & Statistik", description: "Rapport og statistik for kundeklubben")
    subscription_basic.features.create!(title: "Velkomstgave", description: "Giv alle nye medlemmer en velkomstgave efter eget valg")
    subscription_basic.features.create!(title: "QR-kode", description: "Gør det muligt at tilmelde sig via qr-kode")
    subscription_basic.features.create!(title: "Marketing materiale", description: "Startpakke med marketing materiale")
    subscription_basic.features.create!(title: "Egen hjemmeside på clubnovus.dk", description: "Startpakke med marketing materiale")
    subscription_basic.features.create!(title: "Support og rådgiving", description: "Få hjælp og rådgivning til kampagner og administration af kundeklubben")

    
    5.times do |s|
      if s == 1#!MerchantStore.all.any?
        #Creates default inactive store for admin purposes
        store = MerchantStore.create!(description: 'Michels karameller er bare dejlige', email: "test@store345.dk", short_description: 'Michels karameller er bare dejlige', phone: "48391754", street: 'Klostervangen', house_number: '34', 
            postal_code: '3360', city: 'Liseleje', country: 'Denmark', owner: 'Michel Hansen', store_name: 'Michels karameller', sms_keyword: "cn#{s+1}", active: false)
    
        store.create_subscription_plan(start_date: Time.now, subscription_type_id: subscription_basic.id)

        #Create backend admin user
        user = User.create!(
                 email: "michelhansen75@hotmail.com",
                 password: 'testtest75',
                 password_confirmation: 'testtest75')
        merchant_user = store.merchant_users.create!(name: "Michel Kenneth Hansen",
                role: "Sales clerk", phone: '99999999')
        user.sub = merchant_user
        user.save! 

        #Create special user for switching to other stores - log in as
        user = User.create!(
                 email: "admin_user@clubnovus.dk",
                 password: 'testtest75',
                 password_confirmation: 'testtest75')
        merchant_user = store.merchant_users.create!(name: "Club Novus Administrator",
                role: "Administrator", phone: '88888888')
        user.sub = merchant_user
        user.save! 
      else
        description = 'Lorem Ipsum Lorem Ipsum Lorem Ipsum'
        short_description =  'Lorem Ipsum Lorem Ipsum Lorem Ipsum'
        street = 'Nørregade'
        house_number = house_numbers[s]
        email = "test@store#{s+1}.dk"
        postal_code = '3300'
        city = 'Frederiksværk'
        country = 'Denmark'
        owner = Faker::Name.name
        store_name = "Cafe & Steakhouse #{s+1}"
        phone = "41415210"
        sms_keyword = "CN#{s+1}"  
        store = MerchantStore.create(description: description, short_description: short_description, email: email, phone: phone, street: street, house_number: house_number, 
          postal_code: postal_code, city: city, country:'Denmark', owner: owner, store_name: store_name, sms_keyword: sms_keyword, active: true)

        #Create average user record for merchant user
        name  = Faker::Name.name
        email = "test-#{s+1}@clubnovustest.dk"
        password  = "testtest75"

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

      #Create sample invoice for previous month
      store.invoices.create!( period_start: (Time.zone.now - 1.month).beginning_of_month, period_end: (Time.zone.now - 1.month).end_of_month,
                              amount_ex_moms: '199.95', amount_incl_moms: '250.00', comment: 'Lidt for højt sms-forbrug', paid: true)
      store.invoices.create!( period_start: (Time.zone.now - 2.month).beginning_of_month, period_end: (Time.zone.now - 2.month).end_of_month,
                              amount_ex_moms: '199.95', amount_incl_moms: '250.00', comment: 'Lidt for højt sms-forbrug', paid: true)


      #Create subscriber for each merchant     
      5.times do |n| 
        first_name = Faker::Name.first_name
        last_name = Faker::Name.last_name
        postal_code = "3360"
        city = "Frederiksværk"
        gender = "W"
        email = "test-#{s}-#{n}@clubnovustest.dk"
        
        #Adding my phone number for my own store
        phone = ""
        begin
          phone = Random.rand(11111111..99999999).to_s
        end while Member.exists?(phone: phone)
          
        
        password  = "testtest75"
        member_user = User.create!(
                 email: email,
                 password: password,
                 password_confirmation: password)
        member = Member.create!(  first_name: first_name,
                                  last_name: last_name,
                                  postal_code: postal_code,
                                  city: city,
                                  gender: gender,
                                  birthday: Date.today,
                                  phone: phone,
                                  origin:'store',
                                  terms_of_service: true)
        member_user.sub = member
        member_user.save!
        store.subscribers.create!(start_date: Date.today, member_id: member.id)              
      end#end creation of members per merchant

      #Create inactive offers
      5.times do |n|
        title = "Tilbud på kaffe"
        description = "Lorem ipsum Lorem ipsum Lorem ipsum"
        valid_from_text = (Time.now - 50.days).to_s
        valid_to_text = (Time.now - 10.days).to_s
        store.offers.create!(title: title, description: description, valid_from_text: valid_from_text, valid_to_text: valid_to_text)
        #Adding dummy container for image
        store.create_image()
      end

      #Create active offers
      5.times do |n|
        title = "Tilbud på chocolade"
        description = "Lorem ipsum Lorem ipsum Lorem ipsum"
        valid_from_text = (Time.now - 5.days).to_s
        valid_to_text = (Time.now + 20.days).to_s
        store.offers.create!(title: title, description: description, valid_from_text: valid_from_text, valid_to_text: valid_to_text)
        #Adding dummy container for image
        store.create_image()
      end

      #Create business hours
      7.times do |n|
        weekday = (Date.today.beginning_of_week + n)
        
        if n == 6
          store.business_hours.create!(day: (n+1), day_text: I18n.l(weekday, :format => "%A"), closed: true, open_time: Time.new(2013, 8, 29, 8, 30, 0), close_time: Time.new(2013, 8, 29, 16, 30, 0))
        else
          store.business_hours.create!(day: (n+1), day_text: I18n.l(weekday, :format => "%A"), closed: false, open_time: Time.new(2013, 8, 29, 8, 30, 0), close_time: Time.new(2013, 8, 29, 16, 30, 0))
        end

      end 

      #Create event history
      7.times do |n|
        store.event_histories.create!(description: Faker::Lorem.words(10), event_type: "login") 
      end 

      #Create welcome offer
      store.create_welcome_offer!(description: "Kære medlem,\nDu har vundet en kasse Kinder-Æg.", active: true)
       

    end#end loop

    #Create one standalone member with unique email
      1.times do |n| 
        first_name = "Michel"
        last_name = "Hansen"
        postal_code = "3360"
        city = "Liseleje"
        gender = "W"
        email = "scoop751@hotmail.com"
        phone = "48391754"
        password  = "testtest75"
        
        member_user = User.create!(
                 email: email,
                 password: password,
                 password_confirmation: password)
        member = Member.create!(  first_name: first_name,
                                  last_name: last_name,
                                  postal_code: postal_code,
                                  city: city,
                                  gender: gender,
                                  birthday: Date.today,
                                  phone: phone,
                                  origin: 'store',
                                  terms_of_service: true)
        member_user.sub = member
        member_user.save!
        #Associate standalone member with one store
        MerchantStore.first.subscribers.create!(start_date: Date.today, member_id: member.id)
      end #end creation of special standalone member

      #Create one backend admin with unique email
      1.times do |n| 
        name = "Niels Hansen"
        postal_code = "3360"
        gender = "W"
        email = "info@disruptx.dk"
        phone = "48391754"
        password  = "testtest75"
        
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