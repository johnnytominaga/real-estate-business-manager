json.array! @properties do |property|
  json.extract! property, :id, :area_id, :owner_phone_number, :owner_name, :owner_phone_country_code, :owner_additional_info, :location_id, :bedrooms, :bathrooms, :kitchens, :property_type,
    :price, :premium, :address, :description, :style, :lift, :ac, :roof,
    :balconies, :yard, :seafront, :seaview, :swimming_pool, :jacuzzi, :unfurnished, :permit_class,
    :sqm, :office_rooms, :floor, :deposit, :electrics, :obs, :availability_date, :pics, :listed_by,
    :contract_type, :bookable, :active, :payment_format, :condition, :updated_by, :flat_no, :not_answering, :stop_calling, :old_id, property_photos: []
end
