class AddCountryCodeToPropertiesAndLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :owners, :phone_country_code, :string, default: "MT"
  end
end
