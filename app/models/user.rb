class User < ActiveRecord::Base
	authenticates_with_sorcery!
	attr_accessible :email, :password, :password_confirmation, :last_login_at, :last_logout_at, :last_activity_at
	belongs_to :sub, :polymorphic => true

	#This regXP is used for validating passwords (using look ahead assertions). At least 8 characters with at least one number.
	#http://stackoverflow.com/questions/11992544/validating-password-using-regex
  	PASSWORD_REQ = %r{\A(?=.*[a-zA-Z])(?=.*[0-9]).{8,30}\z}
  	validate :password_check

	#https://github.com/NoamB/sorcery/issues/125#issuecomment-18250206
	#http://stackoverflow.com/questions/16617717/why-does-factorygirlbuild-work-with-sorcery-but-not-factorygirlcreate
	validates :password, presence: true, :on => :create
	#Validering skal virke ved create og edit for merchantusers
	validates :password, length:{ in: 8..20 }, :allow_blank => true, :if => "sub_type='MerchantUser'"
	 validates :password, :confirmation => true, 
    	:unless => Proc.new { |a| a.password.blank? }, :if => "sub_type='MerchantUser'"

    #Validering skal kun virke ved create members
	validates :password, length:{ in: 8..30 }, :allow_blank => true, :if => "sub_type='Member'", :on => :create
	validates :password, :confirmation => true, 
    	:unless => Proc.new { |a| a.password.blank? }, :if => "sub_type='Member'", :on => :create
	#Validering virker i browser og test-rake, men skal testes yderligere: if: ->{ crypted_password.blank? }#, :on => :create
  	
  	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
    validates :active, :inclusion => { :in => [true, false] }

    private
    	def password_check
    		if self.password != "" && !self.password.match(PASSWORD_REQ)
        		errors.add(:password, I18n.t(:invalid_password, :scope => [:business_validations, :user]) )
      		end
    	end
end
