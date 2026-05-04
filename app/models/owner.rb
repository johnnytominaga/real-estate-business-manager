class Owner < ApplicationRecord
  has_many :properties, dependent: :destroy
  validates :phone_number, presence: true, uniqueness: true, length: {maximum: 15}, format: { with: /\A\d+\z/, message: "Only numbers: the country code will be added when you select Country code." }
  validates :phone_country_code, presence: true, length: {maximum: 2}

  def full_phone_number
    @owner_country = Country[self.phone_country_code] if !self.phone_country_code.blank?
    if !self.phone_country_code.blank?
      @owner_country_code = @owner_country.country_code
    else
      @owner_country_code = ""
    end
    @owner_phone = '+' + @owner_country_code +" "+ self.phone_number
    @owner_phone.to_s
  end

  def remind_to_call(content, user_id)
    Notification.create(content: content, user_id: user_id)
  end

end
