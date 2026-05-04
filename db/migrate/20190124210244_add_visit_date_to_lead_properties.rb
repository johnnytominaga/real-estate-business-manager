class AddVisitDateToLeadProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :lead_properties, :visit_date, :datetime
  end
end
