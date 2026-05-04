class Lead < ApplicationRecord
  has_many :lead_locations, dependent: :destroy
  has_many :locations, through: :lead_locations
  has_many :lead_areas, dependent: :destroy
  has_many :areas, through: :lead_areas
  has_many :lead_properties, dependent: :destroy
  has_many :properties, through: :lead_properties
  has_many :lead_phases, dependent: :destroy
  has_many :phases, through: :lead_phases
  belongs_to :user, optional: true
  has_one_attached :avatar

  accepts_nested_attributes_for :lead_areas, allow_destroy: true, reject_if: :empty_area?
  accepts_nested_attributes_for :lead_properties, allow_destroy: true
  accepts_nested_attributes_for :lead_locations, allow_destroy: true
  accepts_nested_attributes_for :lead_phases, allow_destroy: true

  validates :name, :phone, :budget, :contract_type, :check_in_date, presence: true
  validates_associated :lead_areas

  enum bedrooms: { "Studio": 0, "1 Bedroom": 1, "2 Bedrooms": 2, "3 Bedrooms": 3, "More than 4 bedrooms": 4 }
  enum budget: {
                "Up to €800": 1, "€800 - 900": 2, "€900 - 1,100": 3, "€1,100 - 1,500": 4, "Over €1,500": 5,
                "Up to €100,000": 6, "€100,001 - 200,000": 7, "€200,001 - 300,000": 8, "€300,001 - 450,000": 9, "Over €450,000": 10,
                "Up to €15/day": 11, "€16 - 25/day": 12, "€26 - 40/day": 13, "€41 - 100/day": 14, "€101 - 200/day": 15, "Over €201/day": 16
                }
  enum contract_type: { Rent: 1, Sales: 2, "Commercial lease": 3, "Commercial sale": 4 }

  enum contract_period: { 'Up to a month': 30, '1 to 5 months': 150, '6 months': 180, '1 year': 365, 'Over 1 year': 720 }

  def full_phone_number
    @lead_country = Country[self.phone_country_code] if !self.phone_country_code.blank?
    if !self.phone_country_code.blank?
      @lead_country_code = @lead_country.country_code
    else
      @lead_country_code = ""
    end
    @lead_phone = '+' + @lead_country_code +" "+ self.phone
    @lead_phone.to_s

  end

  def create_notification(content)
    if self.user_id?
      Notification.create(content: content, user_id: self.user_id)
    else
      @admins = User.where('role_id = ? OR role_id = ?', 3, 4).where.not(id: 4) #Manager or Admin
      @admins.each do |admin|
        Notification.create(content: content, user_id: admin.id)
      end
    end
  end

  def create_manager_notification(content)
    @admins = User.where('role_id = ? OR role_id = ?', 3, 4).where.not(id: 4) #Manager or Admin
    @admins.each do |admin|
      Notification.create(content: content, user_id: admin.id)
    end
  end

  def min_budget
    if self.budget == "Up to €800"
      0
    elsif self.budget == "€800 - 900"
      650
    elsif self.budget == "€900 - 1,100"
      800
    elsif self.budget == "€1,100 - 1,500"
      950
    elsif self.budget == "Over €1,500"
      1300
    elsif self.budget == "Up to €100,000"
      0
    elsif self.budget == "€100,001 - 200,000"
      90000
    elsif self.budget == "€200,001 - 300,000"
      180000
    elsif self.budget == "€300,001 - 450,000"
      280000
    elsif self.budget == "Over €450,000"
      420000
    elsif self.budget == "Up to €15/day"
      0
    elsif self.budget == "€16 - 25/day"
      13
    elsif self.budget == "€26 - 40/day"
      22
    elsif self.budget == "€41 - 100/day"
      35
    elsif self.budget == "€101 - 200/day"
      80
    elsif self.budget == "Over €201/day"
      170
    end
  end

  def max_budget
    if self.budget == "Up to €800"
      850
    elsif self.budget == "€800 - 900"
      1000
    elsif self.budget == "€900 - 1,100"
      1250
    elsif self.budget == "€1,100 - 1,500"
      1650
    elsif self.budget == "Over €1,500"
      20000
    elsif self.budget == "Up to €100,000"
      110000
    elsif self.budget == "€100,001 - 200,000"
      230000
    elsif self.budget == "€200,001 - 300,000"
      340000
    elsif self.budget == "€300,001 - 450,000"
      500000
    elsif self.budget == "Over €450,000"
      1000000000
    elsif self.budget == "Up to €15/day"
      18
    elsif self.budget == "€16 - 25/day"
      30
    elsif self.budget == "€26 - 40/day"
      45
    elsif self.budget == "€41 - 100/day"
      120
    elsif self.budget == "€101 - 200/day"
      250
    elsif self.budget == "Over €201/day"
      1000000
    end
  end

  scope :budget_range, -> (price, contract_type) {
    if price.between?(0, 750) && contract_type == "Rent"
      where("budget BETWEEN ? AND ?", 1, 2)
    elsif price.between?(751, 900) && contract_type == "Rent"
      where("budget BETWEEN ? AND ?", 1, 3)
    elsif price.between?(901, 1100) && contract_type == "Rent"
      where("budget BETWEEN ? AND ?", 2, 4)
    elsif price.between?(1101, 1500) && contract_type == "Rent"
      where("budget BETWEEN ? AND ?", 3, 5)
    elsif price > 1500 && contract_type == "Rent"
      where("budget BETWEEN ? AND ?", 4, 5)
    elsif (price.between?(0, 100000) && contract_type == "Sales") || (price.between?(0, 100000) && contract_type == "Commercial sale")
      where("budget BETWEEN ? AND ?", 6 ,7)
    elsif (price.between?(100001, 200000) && contract_type == "Sales") || (price.between?(0, 100000) && contract_type == "Commercial sale")
      where("budget BETWEEN ? AND ?", 6 ,8)
    elsif (price.between?(200001, 300000) && contract_type == "Sales") || (price.between?(0, 100000) && contract_type == "Commercial sale")
      where("budget BETWEEN ? AND ?", 7, 9)
    elsif (price.between?(300001, 450000) && contract_type == "Sales") || (price.between?(0, 100000) && contract_type == "Commercial sale")
      where("budget BETWEEN ? AND ?", 8,10)
    elsif (price > 450000 && contract_type == "Sales") || (price.between?(0, 100000) && contract_type == "Commercial sale")
      where("budget BETWEEN ? AND ?", 9, 10)
    elsif price.between?(0, 15) && contract_type == "Commercial lease"
      where("budget BETWEEN ? AND ?", 11, 12)
    elsif price.between?(16, 25) && contract_type == "Commercial lease"
      where("budget BETWEEN ? AND ?", 11, 13)
    elsif price.between?(26, 40) && contract_type == "Commercial lease"
      where("budget BETWEEN ? AND ?", 12, 14)
    elsif price.between?(41, 100) && contract_type == "Commercial lease"
      where("budget BETWEEN ? AND ?", 13, 15)
    elsif price.between?(101, 200) && contract_type == "Commercial lease"
      where("budget BETWEEN ? AND ?", 14, 16)
    elsif price > 200 && contract_type == "Commercial lease"
      where("budget BETWEEN ? AND ?", 15, 16)

    end
  }


  private

    def empty_area?(att)
      att['area_id'].blank?
    end

end
