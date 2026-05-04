class AddProposalAmountToLeadProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_properties, :proposal_amount, :integer
  end
end
