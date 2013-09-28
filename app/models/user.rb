class User < ActiveRecord::Base
	authenticates_with_sorcery!
	attr_accessible :email, :password, :password_confirmation, :last_login_at, :last_logout_at, :last_activity_at
	belongs_to :sub, :polymorphic => true

	#https://github.com/NoamB/sorcery/issues/125#issuecomment-18250206
	#http://stackoverflow.com/questions/16617717/why-does-factorygirlbuild-work-with-sorcery-but-not-factorygirlcreate
	validates :password, length:{ in: 8..20 }, if: ->{ crypted_password.blank? }
    validates :password, :confirmation => true,
    	:unless => Proc.new { |a| a.password.blank? }
  	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
    validates :active, :inclusion => { :in => [true, false] }
end
