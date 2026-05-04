class AddContractPeriodToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :contract_period, :integer
  end
end
