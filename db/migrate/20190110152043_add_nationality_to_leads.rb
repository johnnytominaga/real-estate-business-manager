class AddNationalityToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :no_of_people, :integer
    add_column :leads, :nationality, :string
    remove_column :leads, :status
  end
end
