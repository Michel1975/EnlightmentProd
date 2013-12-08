#encoding: utf-8
namespace :db do
  desc "Fill database with sample data"
  task load_start_data: :environment do
    puts "Loading subscribtion data..."
  	#********Start load data for initial basic subscription in database**********
    subscription_basic = SubscriptionType.create!(name: "Basis medlemskab", monthly_price: '199.95')
    subscription_basic.features.create!(title: "Online promotion", description: "Skab større synlighed på nettet")
    subscription_basic.features.create!(title: "Sms kampagnemodul", description: "Lav fantastiske sms-kampagner og skab meromsætning")
    subscription_basic.features.create!(title: "Rapport & Statistik", description: "Rapport og statistik for kundeklubben")
    subscription_basic.features.create!(title: "Velkomstgave", description: "Giv alle nye medlemmer en velkomstgave efter eget valg")
    subscription_basic.features.create!(title: "QR-kode", description: "Gør det muligt at tilmelde sig via qr-kode")
    subscription_basic.features.create!(title: "Marketing materiale", description: "Startpakke med marketing materiale")
    subscription_basic.features.create!(title: "Egen hjemmeside på clubnovus.dk", description: "Startpakke med marketing materiale")
    subscription_basic.features.create!(title: "Support og rådgiving", description: "Få hjælp og rådgivning til kampagner og administration af kundeklubben")
  	#*********End load data for initial basic subscription in database*************
  	
    #********Start load data for initial basic subscription in database**********
    subscription_test = SubscriptionType.create!(name: "Test medlemskab", monthly_price: '0.00')
    subscription_test.features.create!(title: "Online promotion", description: "Skab større synlighed på nettet")
    subscription_test.features.create!(title: "Sms kampagnemodul", description: "Lav fantastiske sms-kampagner og skab meromsætning")
    subscription_test.features.create!(title: "Rapport & Statistik", description: "Rapport og statistik for kundeklubben")
    subscription_test.features.create!(title: "Velkomstgave", description: "Giv alle nye medlemmer en velkomstgave efter eget valg")
    subscription_test.features.create!(title: "QR-kode", description: "Gør det muligt at tilmelde sig via qr-kode")
    subscription_test.features.create!(title: "Marketing materiale", description: "Startpakke med marketing materiale")
    subscription_test.features.create!(title: "Egen hjemmeside på clubnovus.dk", description: "Startpakke med marketing materiale")
    subscription_test.features.create!(title: "Support og rådgiving", description: "Få hjælp og rådgivning til kampagner og administration af kundeklubben")
    #*********End load data for initial basic subscription in database*************

    puts "Subscribtion data done..."

  	puts "Loading default merchant store for admin-backend..."
  	#*********Start create default admin-store for backend*************
    store = MerchantStore.create!(description: 'Butik til anvendelse i backend-administration', email: "admin_user@clubnovus.dk", short_description: 'Butik til anvendelse i backend-administration', phone: "24600819", street: 'Klostervangen', house_number: '34', 
        postal_code: '3360', city: 'Liseleje', country: 'Denmark', owner: 'Michel Kenneth Hansen', store_name: 'Backend Admin', sms_keyword: "CN_admin", active: false)

    store.create_subscription_plan(start_date: Time.now, subscription_type_id: subscription_basic.id)
	  #*********End create default admin-store for backend*************
	  puts "Loading default merchant store for admin-backend...done"

	  puts "Loading admin users for backend..."
 	  #*********Start create admin users for backend*************
    user = User.create!(
             email: "michel@clubnovus.dk",
             password: 'test500test45',
             password_confirmation: 'test500test45')
    merchant_user = store.merchant_users.create!( name: "Michel Kenneth Hansen",
                                                  role: "Administrator", phone: '24600819')
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
    #*********End create admin users for backend*************
	  puts "Loading admin users for backend...done"

    puts "Loading selected status codes for handling callbacks from CIM Mobil..."
    #*********Start loading selected status codes for handling callbacks from CIM Mobil**********
	  status_codes = Hash.new
	  status_codes[0] = "Besked afsendt"
	  status_codes[1] = "Besked leveret"
	  status_codes[14] = "Udsendelse igang"
	  status_codes[129] = "Klar til udsendelse"
	  status_codes[130] = "Udsendelse igang"
	  
    #Custom code used as init value
	  status_codes[500] = "Udsendelse planlagt"
	  
    #Custom code for not-handled error codes
	  status_codes[999] = "Beskeden kunne ikke sendes"

	  status_codes.each do |key, value|
		 StatusCode.create!(name: key, description: value)
	  end
	  #*********End loading selected status codes for handling callbacks from CIM Mobil**********
	  puts "Loading selected status codes for handling callbacks from CIM Mobil...done"
end#End task

end#Close namespace