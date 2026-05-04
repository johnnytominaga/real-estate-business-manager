class LeadLocation < ApplicationRecord
  belongs_to :location
  belongs_to :lead
end
