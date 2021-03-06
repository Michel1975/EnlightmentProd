# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131205153338) do

  create_table "backend_admins", :force => true do |t|
    t.string   "name"
    t.string   "role"
    t.boolean  "admin",      :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "business_hours", :force => true do |t|
    t.integer  "day"
    t.time     "open_time"
    t.time     "close_time"
    t.integer  "merchant_store_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "day_text"
    t.boolean  "closed",            :default => false
  end

  add_index "business_hours", ["merchant_store_id"], :name => "index_business_hours_on_merchant_store_id"

  create_table "campaign_members", :force => true do |t|
    t.integer  "subscriber_id"
    t.integer  "campaign_id"
    t.string   "status"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "campaign_members", ["campaign_id"], :name => "index_campaign_members_on_campaign_id"
  add_index "campaign_members", ["subscriber_id", "campaign_id"], :name => "index_campaign_members_on_subscriber_id_and_campaign_id", :unique => true
  add_index "campaign_members", ["subscriber_id"], :name => "index_campaign_members_on_subscriber_id"

  create_table "campaigns", :force => true do |t|
    t.string   "title"
    t.text     "message"
    t.string   "status"
    t.datetime "activation_time"
    t.string   "message_group_id"
    t.integer  "merchant_store_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.decimal  "total_cost"
    t.integer  "campaign_members_count"
    t.boolean  "acknowledgement",        :default => false
  end

  add_index "campaigns", ["merchant_store_id"], :name => "index_campaigns_on_merchant_store_id"
  add_index "campaigns", ["message_group_id"], :name => "index_campaigns_on_message_group_id", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "event_histories", :force => true do |t|
    t.text     "description"
    t.string   "event_type"
    t.integer  "merchant_store_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "event_histories", ["merchant_store_id"], :name => "index_event_histories_on_merchant_store_id"

  create_table "features", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "subscription_type_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "features", ["subscription_type_id"], :name => "index_features_on_subscription_type_id"

  create_table "feed_entries", :force => true do |t|
    t.string   "name"
    t.text     "summary"
    t.string   "url"
    t.datetime "published_at"
    t.string   "guid"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "imageable_type"
    t.integer  "imageable_id"
    t.string   "picture"
    t.integer  "size"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "invoices", :force => true do |t|
    t.date     "period_start"
    t.date     "period_end"
    t.decimal  "amount_ex_moms"
    t.decimal  "amount_incl_moms"
    t.text     "comment"
    t.integer  "merchant_store_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "paid",              :default => false
  end

  add_index "invoices", ["merchant_store_id"], :name => "index_invoices_on_merchant_store_id"

  create_table "members", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "postal_code"
    t.string   "gender"
    t.date     "birthday"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "terms_of_service",        :default => false
    t.boolean  "complete",                :default => false
    t.string   "origin"
    t.string   "access_key"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.boolean  "email_confirmed",         :default => false
    t.boolean  "phone_confirmed",         :default => false
    t.integer  "phone_confirmation_code"
  end

  add_index "members", ["phone"], :name => "index_members_on_phone", :unique => true

  create_table "merchant_stores", :force => true do |t|
    t.boolean  "active",                      :default => false
    t.string   "store_name"
    t.text     "description"
    t.string   "owner"
    t.string   "street"
    t.string   "house_number"
    t.string   "postal_code"
    t.string   "city"
    t.string   "country"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "sms_keyword"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "phone"
    t.text     "short_description"
    t.integer  "subscribers_count"
    t.integer  "message_notifications_count"
    t.string   "email"
  end

  add_index "merchant_stores", ["sms_keyword"], :name => "index_merchant_stores_on_sms_keyword", :unique => true

  create_table "merchant_users", :force => true do |t|
    t.string   "name"
    t.string   "role"
    t.boolean  "admin",             :default => true
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "merchant_store_id"
    t.string   "phone"
  end

  create_table "message_errors", :force => true do |t|
    t.string   "text"
    t.string   "recipient"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "error_type"
  end

  create_table "message_notifications", :force => true do |t|
    t.string   "recipient"
    t.integer  "status_code_id"
    t.string   "notification_type"
    t.string   "message_id"
    t.integer  "merchant_store_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "campaign_group_id"
  end

  add_index "message_notifications", ["merchant_store_id"], :name => "index_message_notifications_on_merchant_store_id"
  add_index "message_notifications", ["message_id"], :name => "index_message_notifications_on_message_id", :unique => true

  create_table "offers", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.date     "valid_from"
    t.date     "valid_to"
    t.integer  "merchant_store_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "offers", ["merchant_store_id"], :name => "index_offers_on_merchant_store_id"

  create_table "qr_images", :force => true do |t|
    t.string   "qrimageable_type"
    t.integer  "qrimageable_id"
    t.string   "picture"
    t.integer  "size"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "status_codes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "subscriber_histories", :force => true do |t|
    t.string   "event_type"
    t.integer  "member_id"
    t.integer  "merchant_store_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "member_phone"
  end

  create_table "subscribers", :force => true do |t|
    t.integer  "member_id"
    t.integer  "merchant_store_id"
    t.date     "start_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "subscribers", ["member_id"], :name => "index_subscribers_on_member_id"
  add_index "subscribers", ["merchant_store_id", "member_id"], :name => "index_subscribers_on_merchant_store_id_and_member_id", :unique => true
  add_index "subscribers", ["merchant_store_id"], :name => "index_subscribers_on_merchant_store_id"

  create_table "subscription_plans", :force => true do |t|
    t.integer  "merchant_store_id"
    t.integer  "subscription_type_id"
    t.date     "start_date"
    t.date     "cancel_date"
    t.boolean  "active",               :default => true
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "subscription_plans", ["merchant_store_id"], :name => "index_subscription_plans_on_merchant_store_id"
  add_index "subscription_plans", ["subscription_type_id"], :name => "index_subscription_plans_on_subscription_type_id"

  create_table "subscription_types", :force => true do |t|
    t.string   "name"
    t.decimal  "monthly_price"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer  "sub_id"
    t.string   "sub_type"
    t.boolean  "active",                          :default => true
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address"
  end

  add_index "users", ["last_logout_at", "last_activity_at"], :name => "index_users_on_last_logout_at_and_last_activity_at"
  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"
  add_index "users", ["sub_id", "sub_type"], :name => "index_users_on_sub_id_and_sub_type", :unique => true
  add_index "users", ["sub_id"], :name => "index_users_on_sub_id"
  add_index "users", ["sub_type"], :name => "index_users_on_sub_type"

  create_table "welcome_offers", :force => true do |t|
    t.boolean  "active",            :default => false
    t.text     "description"
    t.integer  "merchant_store_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "welcome_offers", ["merchant_store_id"], :name => "index_welcome_offers_on_merchant_store_id"

end
