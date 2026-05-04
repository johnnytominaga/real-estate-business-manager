class AddMeetingPointToLeadProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_properties, :meeting_point, :string
  end
end
