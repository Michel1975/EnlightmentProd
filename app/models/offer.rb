class Offer < ActiveRecord::Base
  scope :active, lambda {where("valid_from <= ? and valid_to >= ?", Time.zone.now, Time.zone.now ) }
  scope :completed, lambda {where("valid_to < ?", Time.zone.now ) }
  belongs_to :merchant_store
  
  attr_accessible :title, :description, :valid_from_text, :valid_to_text, :remove_offer_picture, :image_attributes
  attr_writer :valid_from_text, :valid_to_text
  
  has_one :image, :as => :imageable, dependent: :destroy
  
  #The use of this means that we must re-build image instance in create and update validation errors - in controllers.
  accepts_nested_attributes_for :image, :reject_if => lambda { |a| a[:picture].blank? }

  before_validation :save_dates
  
  validates :description, :title, :valid_from, :valid_to, :merchant_store_id, presence: true
  validates :title, :length => { :maximum => 30}, :allow_blank => true
  validate :validate_dates_create, :on => :create
  validate :validate_dates_update, :on => :update
  
  def valid_from_text
    @valid_from_text || valid_from.try(:strftime, "%d-%m-%Y")
  end

  def valid_to_text
    @valid_to_text || valid_to.try(:strftime, "%d-%m-%Y")
  end

  private
    def save_dates
      if @valid_from_text.present? 
        self.valid_from = Time.zone.parse( @valid_from_text )
      end
      if @valid_to_text.present?
        self.valid_to = Time.zone.parse( @valid_to_text )
      end

    end

    def validate_dates_create
      if self.valid_from.present? && self.valid_from.to_date < Date.today
          errors.add(:valid_from, I18n.t(:invalid_valid_from, :scope => [:business_validations, :offer]) )
      end
      if self.valid_to.present? && self.valid_to.to_date < Date.today
          errors.add(:valid_to, I18n.t(:invalid_valid_to, :scope => [:business_validations, :offer]) )
      end

      if self.valid_from.present? && self.valid_to.present? && self.valid_from.to_date > valid_to.to_date
        errors.add(:valid_from, I18n.t(:invalid_interval, :scope => [:business_validations, :offer]) )
      end
    end

    #On updates, old offers may be updated with new valid periods which may be in the past
    def validate_dates_update
      if self.valid_from.present? && self.valid_to.present? && self.valid_from.to_date > valid_to.to_date
        errors.add(:valid_from, I18n.t(:invalid_interval, :scope => [:business_validations, :offer]) )
      end
    end
    
end
