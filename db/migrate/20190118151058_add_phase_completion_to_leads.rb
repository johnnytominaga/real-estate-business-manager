class AddPhaseCompletionToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :information_collected, :boolean
    add_column :leads, :property_found, :boolean
    add_column :leads, :negotiation_completed, :boolean
  end
end
