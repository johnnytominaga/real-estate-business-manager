class Phase < ApplicationRecord
  has_many :lead_phases
  has_many :leads, :through => :lead_phases
end
