class User < ActiveRecord::Base
	attr_accessible :email, :password, :password_confirmation

	belongs_to :sub, :polymorphic => true

	authenticates_with_sorcery!
	
	validates :password, presence: true, :length => { :in => 8..20 }
	validates :password, :confirmation => true,
    	:unless => Proc.new { |a| a.password.blank? }

  	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
    validates :active, :inclusion => { :in => [true, false] }
    validates :sub_id, :sub_type, presence: true
end
