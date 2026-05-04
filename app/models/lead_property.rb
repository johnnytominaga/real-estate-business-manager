class LeadProperty < ApplicationRecord
  belongs_to :property
  belongs_to :lead

  enum status: {
    "Reproved": 1,
    "Suggested by client": 2,
    "Suggested by agent": 3,
    "Shared with client": 4,
    "Approved for visit": 5,
    "Visited": 6,
    "Proposal received": 7,
    "Proposal approved": 8,
    "Deposit paid": 9,
    "Contract signed": 10,
    "Payment sorted": 11
  }

  def convert_to_currency

    if self.proposal_amount && self.lead.contract_type == "Rent"
      ActiveSupport::NumberHelper.number_to_currency(self.proposal_amount, unit: "€", precision: 0).to_s + " per month"
    elsif self.proposal_amount && self.lead.contract_type == "Sales"
      ActiveSupport::NumberHelper.number_to_currency(self.proposal_amount, unit: "€", precision: 0).to_s
    elsif self.proposal_amount && self.lead.contract_type == "Commercial"
      ActiveSupport::NumberHelper.number_to_currency(self.proposal_amount, unit: "€", precision: 0).to_s + " per day"
    else
      ""
    end
  end

end
