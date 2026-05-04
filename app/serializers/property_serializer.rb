class PropertySerializer < ActiveModel::Serializer
  attributes :id, :area_id, :location_id,
    :bedrooms, :bathrooms, :kitchens, :property_type,
    :price, :premium, :address, :description, :style, :lift, :ac, :roof,
    :balconies, :yard, :seafront, :seaview, :swimming_pool, :jacuzzi, :unfurnished, :permit_class,
    :sqm, :office_rooms, :floor, :deposit, :electrics, :obs, :availability_date, :pics, :listed_by,
    :contract_type, :bookable, :active, :payment_format, :condition, :updated_by, :flat_no, :not_answering, :stop_calling, :old_id

  class OwnerSerializer < ActiveModel::Serializer
    attributes :phone_number, :name, :phone_country_code, :additional_info
  end

  belongs_to :owner, serializer: OwnerSerializer, key: :owner
end
