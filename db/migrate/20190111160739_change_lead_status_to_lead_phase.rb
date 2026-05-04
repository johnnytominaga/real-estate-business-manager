class ChangeLeadStatusToLeadPhase < ActiveRecord::Migration[5.2]
  def change
    rename_table :lead_statuses, :lead_phases
    rename_table :statuses, :phases
  end
end
