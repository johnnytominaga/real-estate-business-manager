include ActionView::Helpers::UrlHelper

class Property < ApplicationRecord

  belongs_to :area
  belongs_to :location
  belongs_to :owner
  belongs_to :user, optional: true
  has_many :lead_properties
  has_many :leads, :through => :lead_properties
  has_many_attached :property_photos
  has_many :bookmarks

  # validates :owner_phone_country_code, presence: true
  validates :owner_phone_number, presence: true, length: 3..15, format: { with: /\A\d+\z/, message: "Only numbers: the country code will be added when you select Country code." }
  validates :location_id, presence: true
  validates :contract_type, presence: true
  validates :payment_format, presence: true
  validates :availability_date, presence: true

  validate :availability_date_cannot_be_in_the_past
  validate :image_type

  enum property_type: {
    "Apartment": 1, "Maisonette": 2, "Studio": 3, "Townhouse": 4, "Terraced house": 5,
    "Villa": 6, "Semi detached villa": 7, "Detached villa": 8, "House of character": 9, "House": 10,
    "Farmhouse": 11, "Penthouse": 12, "Bungalow": 13, "Palazzo": 14, "Garage": 15,
    "Land": 16, "Bar": 17, "Cafeteria": 18, "Corner shop": 19, "Dive centre": 20,
    "Office": 21, "Office room": 22, "Warehouse": 23, "Clinic": 24, "Restaurant": 25,
    "Catering": 26, "Salon": 27, "Showroom": 28,
    "Duplex apartment": 29, "Block of apartments": 30,
    "Shop": 31,
    "N/A": 0
  }

  enum permit_class: { "1 - Residential": 1, "2A - Residential institution": 2, "2B - Non-Residential institution": 3,
    "2C - Education": 4, "3A - B&B or Hostel": 5, "3B - Hotel": 6, "3C - Leasure Space": 7, "3D - Sea Leasure": 8,
    "4A - Office": 9, "4B - Retail": 10, "4C - Catering No Cooking": 11, "4D - Catering Cooking": 12
  }

  enum contract_type: { Rent: 1, Sales: 2, "Commercial lease": 3, "Commercial sale": 4, Management: 5 }
  enum payment_format: { Monthly: 1, OneTime: 2, Daily: 3 }
  enum style: { "Unknown": 0, Modern: 1, Luxurious: 2, Classic: 3 }
  enum condition: { "Not informed": 0, "Brand new": 1, "New": 2, "Good": 3,
    "Used": 4, "Renovated": 5, "Needs renovation": 6, "Shell": 7, "Finished": 8,
    "Furnished": 9, "Semi-furnished": 10, "On plan": 11 }

  geocoded_by :full_address
  after_validation :geocode

  ransacker :old_id do
    Arel.sql("to_char(old_id, '9999999')")
  end

  ransacker :id do
    Arel.sql(
      "regexp_replace(
        to_char(\"properties\".\"id\", '9999999'), ' ', '', 'g')"
    )
  end

  def full_address
    [location.name, "Malta"].compact.join(', ') if location.present?
  end

  def owner_phone_number
    owner.try(:phone_number)
  end

  def owner_phone_number=(phone_number)
      self.owner = Owner.find_or_create_by(phone_number: phone_number) if phone_number.present?
  end

  def owner_name
    owner.try(:name)
  end

  def owner_name=(name)
    if owner && !name.blank?
      owner.update_attribute(:name, name)
    end
  end

  def owner_phone_country_code
    owner.try(:phone_country_code)
  end

  def owner_phone_country_code=(country_code)
    if owner && !country_code.blank?
      owner.update_attribute(:phone_country_code, country_code)
    end
  end

  def owner_additional_info
    owner.try(:additional_info)
  end

  def cover_photo(size, host)

    @resize = size + "^"
    @extent = size
    if self.property_photos.length > 0 && self.property_photos[0].content_type.in?(%w(image/jpeg image/png))
      if self.property_photos[0].variable?
        self.property_photos[0].variant(
          combine_options: {
            gravity: 'center',
            'auto-orient': true,
            resize: @resize,
            extent: @extent
          }
        )
      else
        if host.include?('rocklandmalta.com') || host.include?('jr-dev-07')
          "placeholder-rockland.jpg"
        else
          "placeholder.jpg"
        end
      end
    else
      if host.include?('rocklandmalta.com') || host.include?('jr-dev-07')
        "placeholder-rockland.jpg"
      else
        "placeholder.jpg"
      end
    end
  end

  def property_title

    if !self.contract_type.blank?
      if self.contract_type == "Rent" && self.bedrooms? && !self.property_type.blank?
        @property_title = self.bedrooms.to_s + "-Bedroom " + self.property_type + " for rent in " + self.location.name
      elsif self.contract_type == "Sales" && !self.property_type.blank?
        @property_title = self.property_type + " for sale in " + self.location.name
      elsif self.contract_type == "Commercial lease" && !self.property_type.blank?
        @property_title = self.property_type + " to lease in " + self.location.name
      elsif self.contract_type == "Commercial sale" && !self.property_type.blank?
        @property_title = self.property_type + " for sale in " + self.location.name

      else
        @property_title = "Property for " + self.contract_type
      end
      @property_title.to_s
    else
      ""
    end

  end

  def property_price

    if self.price && self.contract_type == "Rent"
      ActiveSupport::NumberHelper.number_to_currency(self.price, unit: "€", precision: 0).to_s + " per month"
    elsif self.price && self.contract_type == "Sales"
      ActiveSupport::NumberHelper.number_to_currency(self.price, unit: "€", precision: 0).to_s
    elsif self.price && self.contract_type == "Commercial lease"
      ActiveSupport::NumberHelper.number_to_currency(self.price, unit: "€", precision: 0).to_s + " per day"
    elsif self.price && self.contract_type == "Commercial sale"
      ActiveSupport::NumberHelper.number_to_currency(self.price, unit: "€", precision: 0).to_s

    else
      ""
    end
  end

  def property_owner
    @owner = Owner.find(self.owner_id)
  end

  def property_owner_phone_number
    @owner_country = Country[self.property_owner.phone_country_code] if !self.property_owner.phone_country_code.blank?
    if !self.property_owner.phone_country_code.blank?
      @owner_country_code = @owner_country.country_code
    else
      @owner_country_code = ""
    end
    @owner_phone = '+' + @owner_country_code +" "+ @owner.phone_number
    @owner_phone.to_s
  end

  def properties_from_owner(except_id)
    if !Property.where("owner_id = ? AND id != ?", self.owner_id, except_id).blank?
      @owner_properties = Property.where("owner_id = ? AND id != ?", self.owner_id, except_id)
    else
      @owner_properties = []
    end
  end

  def share_with_owner
    if !self.property_owner.name.blank? && self.property_owner.name != "0"
      @owner_name = " Owner's name: " + self.property_owner.name + "\r\n\r\n"
    else
      @owner_name = ""
    end

    if self.property_photos.length > 0
      @has_photos = "Pictures available!" + "\r\n\r\n"
    else
      @has_photos = ""
    end

    @share_text = (self.property_title + "\r\n\r\n" +
                            " Available from: " + self.availability_date.to_time.strftime("%d/%m/%Y") + "\r\n\r\n" +
                            " Price: "+ self.property_price + "\r\n\r\n" +
                            @owner_name +
                            @has_photos +
                            " Check property: " + Rails.application.routes.url_helpers.property_url(self.id)) + "\r\n\r\n" +
                            " Click to call: " + Rails.application.routes.url_helpers.owner_url(self.property_owner.id)

  end

  def share_with_owner_encoded
    @share_text_encoded = URI.escape(self.share_with_owner, Regexp.new('[^#{URI::PATTERN::UNRESERVED}]'))
  end

  def share_without_owner
    if !self.property_owner.name.blank? && self.property_owner.name != "0"
      @owner_name = " Owner's name: " + self.property_owner.name + "\r\n\r\n"
    else
      @owner_name = ""
    end

    if self.property_photos.length > 0
      @has_photos = "Pictures available!" + "\r\n\r\n"
    else
      @has_photos = ""
    end

    @share_text_no_owner = (self.property_title + "\r\n\r\n" +
                            " Available from: " + self.availability_date.to_time.strftime("%B %Y") + "\r\n\r\n" +
                            " Price: " + self.property_price + "\r\n\r\n" +
                            " Check property: " + Rails.application.routes.url_helpers.property_url(self.id))
  end

  def share_without_owner_encoded
    @share_text_no_owner_encoded = URI.escape(self.share_without_owner, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def updated_by_user
    if !self.updated_by.nil? && User.find(self.updated_by).nickname? && User.find(self.updated_by).first_name?
      User.find(self.updated_by)
    else
      User.find(2)
    end
  end

  def assigned_to_user
    if !self.assigned_to.nil? && User.find(self.assigned_to).nickname? && User.find(self.assigned_to).first_name?
      User.find(self.assigned_to)
    else
      User.find(2)
    end
  end

  def listed_by_user
    if !self.listed_by.nil? && !self.listed_by != "0" && !User.find(self.listed_by).nickname? && !User.find(self.listed_by).first_name?
      User.find(self.assigned_to)
    else
      User.find(2)
    end
  end

  def suggested_property(lead)
    self.lead_properties.where("lead_id = ?", lead.id).order('created_at DESC').first
  end


# RAILS ADMIN
  attr_accessor :remove_property_photos
  after_save do
    Array(remove_property_photos).each { |id| property_photos.find_by_id(id).try(:purge) }
  end

  rails_admin do
    include_all_fields
    exclude_fields :property_photos
  end

  private

  def availability_date_cannot_be_in_the_past
    if (!availability_date.blank? && availability_date != "0") && availability_date < Date.today
      errors.add(:availability_date, "has to be in the future.")
    end
  end

  def image_type
    property_photos.each do |photo|
      if !photo.content_type.in?(%w(image/jpeg image/png image/gif))
        errors.add(:property_photos, 'must be a JPG, PNG or GIF file')
      end
    end
  end

end
