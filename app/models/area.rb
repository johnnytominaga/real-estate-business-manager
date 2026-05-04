class Area < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :properties, foreign_key: :area_id
  has_many :lead_areas
  has_many :leads, :through => :lead_areas


end
