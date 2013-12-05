class Offer < ActiveRecord::Base
  scope :active, lambda {where("valid_from <= ? and valid_to >= ?", Time.zone.now, Time.zone.now ) }
  scope :completed, lambda {where("valid_to < ?", Time.zone.now ) }
  #scope :scheduled, lambda {where("valid_from > ?", Time.zone.now ) }
  
  attr_accessible :title, :description, :valid_from_text, :valid_to_text, :remove_offer_picture, :image_attributes
  attr_writer :valid_from_text, :valid_to_text
  
  has_one :image, :as => :imageable, dependent: :destroy
  
  accepts_nested_attributes_for :image, :reject_if => lambda { |a| a[:picture].blank? }

  before_validation :save_dates

  belongs_to :merchant_store
  validates :description, :title, :valid_from, :valid_to, :merchant_store_id, presence: true
  validates :title, :length => { :maximum => 30}, :allow_blank => true
  #validate :validate_dates, :on => :create

  def valid_from_text
    @valid_from_text || valid_from.try(:strftime, "%d-%m-%Y")
  end

  def valid_to_text
    @valid_to_text || valid_to.try(:strftime, "%d-%m-%Y")
  end

  private
    def save_dates
      if @valid_from_text && @valid_to_text
        self.valid_from = Time.zone.parse( @valid_from_text )
        self.valid_to = Time.zone.parse( @valid_to_text )
      end
    end

    def validate_dates
      if (self.valid_from < Time.zone.now)
        errors.add(:valid_from, I18n.t(:invalid_valid_from, :scope => [:business_validations, :offer]) )
      end
      if (self.valid_to < Time.zone.now)
        errors.add(:valid_to, I18n.t(:invalid_valid_to, :scope => [:business_validations, :offer]) )
      end

      if (self.valid_from > self.valid_to)
        errors.add(:valid_from, I18n.t(:invalid_interval, :scope => [:business_validations, :offer]) )
      end
    end
end
