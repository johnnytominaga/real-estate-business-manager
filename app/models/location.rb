class Location < ApplicationRecord
  belongs_to :area
  has_many :properties, foreign_key: :location_id
  has_many :lead_locations
  has_many :leads, :through => :lead_locations
end
