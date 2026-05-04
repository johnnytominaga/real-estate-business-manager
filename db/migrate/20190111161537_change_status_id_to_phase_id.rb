class ChangeStatusIdToPhaseId < ActiveRecord::Migration[5.2]
  def change
    rename_column :lead_phases, :status_id, :phase_id
  end
end
