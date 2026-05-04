class Api::V1::PropertiesController < Api::V1::BaseController

  before_action :authenticate_user!

  # class Property < ::Property
  #   def as_json(options = {})
  #     super.merge()
  #   end
  # end

  def index
    if !params[:contract_type].blank?
      @properties = Property.where(contract_type: params[:contract_type]).paginate(per_page: 10)
    else
      @properties = paginate Property.where(sold: [nil, false]), per_page: 10
    end

    render json: {
      properties: @properties.map { |p| p.attributes.merge(photo: url_for(p.cover_photo('medium', request.host))) },
      meta: pagination_dict(@properties),
      is_success: true},
      status: :ok


  end

  def create

    @property = Property.new(property_params)
    @property.save

    render json: @property, status: :created

  end

  def show
    property = Property.find(params[:id])

    if !property.nil?
      property_serializer = PropertySerializer.new(
        property
      )
      render json: {
        property: property_serializer.attributes.merge(photo: url_for(property.cover_photo('medium', request.host))),
        is_success: true},
        status: :ok

    else
      render json: { error: "Invalid ID", is_success: false}, status: 422
    end
  end


  private

  def property_params
    params.require(:property).permit(:area_id, :owner_phone_number, :owner_name, :owner_phone_country_code, :owner_additional_info, :location_id, :bedrooms, :bathrooms, :kitchens, :property_type,
      :price, :premium, :address, :description, :style, :lift, :ac, :roof,
      :balconies, :yard, :seafront, :seaview, :swimming_pool, :jacuzzi, :unfurnished, :permit_class,
      :sqm, :office_rooms, :floor, :deposit, :electrics, :obs, :availability_date, :pics, :listed_by,
      :contract_type, :bookable, :active, :payment_format, :condition, :updated_by, :flat_no, :not_answering, :stop_calling, :old_id, :sold, property_photos: [])
  end

end
