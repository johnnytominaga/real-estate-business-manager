class AddCountryCodeToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :phone_country_code, :string, default: "MT"
  end
end
